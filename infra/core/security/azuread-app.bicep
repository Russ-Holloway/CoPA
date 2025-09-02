// Azure AD App Registration Deployment Script Module
// This module creates an Azure AD App Registration using PowerShell deployment script
// since Microsoft Graph resources cannot be managed directly through ARM templates

@description('Force code for naming compliance')
param forceCode string = 'test'

@description('Display name for the Azure AD application')
param appDisplayName string = 'CoPPA-Policing-Assistant'

@description('The base URL of the web application for redirect URIs')
param webAppUrl string

@description('Resource group location')
param location string = resourceGroup().location

@description('Tags to apply to resources')
param tags object = {}

@description('Whether to create the app registration (set false if already exists)')
param createAppRegistration bool = true

@description('Client secret expiration in months (default: 24 months)')
param clientSecretExpirationMonths int = 24

@description('User-assigned managed identity ID for running deployment scripts')
param managedIdentityId string

// Generate unique names for deployment script resources
var scriptName = 'deploy-azuread-app-${uniqueString(resourceGroup().id, appDisplayName)}'
var scriptStorageAccountName = take('st${forceCode}deploy${substring(uniqueString(resourceGroup().id), 0, 3)}', 24)

// PowerShell script for creating Azure AD App Registration
var powerShellScript = '''
param(
    [string]$AppDisplayName,
    [string]$WebAppUrl,
    [int]$ClientSecretExpirationMonths
)

# Install required modules
Install-Module -Name Az.Accounts -Force -AllowClobber -Scope CurrentUser
Install-Module -Name Az.Resources -Force -AllowClobber -Scope CurrentUser  
Install-Module -Name Microsoft.Graph.Applications -Force -AllowClobber -Scope CurrentUser
Install-Module -Name Microsoft.Graph.Authentication -Force -AllowClobber -Scope CurrentUser

# Connect using managed identity
Connect-AzAccount -Identity

# Get access token and connect to Microsoft Graph
$context = Get-AzContext
$token = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"
$secureToken = ConvertTo-SecureString $token.Token -AsPlainText -Force
Connect-MgGraph -AccessToken $secureToken

# Define redirect URIs
$redirectUris = @(
    "$WebAppUrl/.auth/login/aad/callback",
    "$WebAppUrl/redirect"
)

$logoutUrl = "$WebAppUrl/.auth/logout"

# Check if app already exists
$existingApp = Get-MgApplication -Filter "displayName eq '$AppDisplayName'" -ErrorAction SilentlyContinue

if ($existingApp) {
    Write-Output "App registration '$AppDisplayName' already exists. Using existing app."
    $app = $existingApp
} else {
    Write-Output "Creating new app registration: $AppDisplayName"
    
    # Create app registration
    $appParams = @{
        DisplayName = $AppDisplayName
        SignInAudience = "AzureADMyOrg"
        Web = @{
            RedirectUris = $redirectUris
            LogoutUrl = $logoutUrl
            ImplicitGrantSettings = @{
                EnableIdTokenIssuance = $true
                EnableAccessTokenIssuance = $false
            }
        }
        RequiredResourceAccess = @(
            @{
                ResourceAppId = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph
                ResourceAccess = @(
                    @{
                        Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"  # User.Read
                        Type = "Scope"
                    },
                    @{
                        Id = "37f7f235-527c-4136-accd-4a02d197296e"  # openid
                        Type = "Scope"
                    },
                    @{
                        Id = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"  # email
                        Type = "Scope"
                    },
                    @{
                        Id = "14dad69e-099b-42c9-810b-d002981feec1"  # profile
                        Type = "Scope"
                    }
                )
            }
        )
    }
    
    $app = New-MgApplication @appParams
}

# Create or get service principal (Enterprise Application)
$servicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$($app.AppId)'" -ErrorAction SilentlyContinue

if (-not $servicePrincipal) {
    Write-Output "Creating service principal (Enterprise Application)"
    $servicePrincipal = New-MgServicePrincipal -AppId $app.AppId -AccountEnabled $true -AppRoleAssignmentRequired $true
} else {
    Write-Output "Service principal already exists. Updating settings."
    Update-MgServicePrincipal -ServicePrincipalId $servicePrincipal.Id -AccountEnabled $true -AppRoleAssignmentRequired $true
}

# Create client secret
$secretName = "CoPPA-Deployment-Secret-$(Get-Date -Format 'yyyyMMdd')"
$secretEnd = (Get-Date).AddMonths($ClientSecretExpirationMonths)

$passwordCredential = @{
    DisplayName = $secretName
    EndDateTime = $secretEnd
}

$secret = Add-MgApplicationPassword -ApplicationId $app.Id -BodyParameter $passwordCredential

# Set outputs for ARM template (required for deployment script outputs)
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['ApplicationId'] = $app.AppId
$DeploymentScriptOutputs['ServicePrincipalId'] = $servicePrincipal.Id  
$DeploymentScriptOutputs['ClientSecret'] = $secret.SecretText
$DeploymentScriptOutputs['SecretExpiry'] = $secretEnd.ToString("yyyy-MM-dd")

# Also output results for logging
$result = @{
    ApplicationId = $app.AppId
    ApplicationObjectId = $app.Id
    ServicePrincipalId = $servicePrincipal.Id
    ClientSecret = $secret.SecretText
    TenantId = (Get-MgContext).TenantId
    RedirectUris = $redirectUris
    LogoutUrl = $logoutUrl
    SecretExpiry = $secretEnd.ToString("yyyy-MM-dd")
}

Write-Output ($result | ConvertTo-Json -Depth 3)
'''

// Storage account for deployment script
resource scriptStorageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: scriptStorageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Deployment script to create Azure AD App Registration
resource appRegistrationScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = if (createAppRegistration) {
  name: scriptName
  location: location
  tags: tags
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    azPowerShellVersion: '9.0'
    scriptContent: powerShellScript
    arguments: '-AppDisplayName "${appDisplayName}" -WebAppUrl "${webAppUrl}" -ClientSecretExpirationMonths ${clientSecretExpirationMonths}'
    supportingScriptUris: []
    storageAccountSettings: {
      storageAccountName: scriptStorageAccount.name
      storageAccountKey: scriptStorageAccount.listKeys().keys[0].value
    }
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT30M'
  }
}

// Outputs for consumption by main template
output applicationId string = createAppRegistration ? (appRegistrationScript.?properties.?outputs.?ApplicationId ?? '') : ''
output servicePrincipalId string = createAppRegistration ? (appRegistrationScript.?properties.?outputs.?ServicePrincipalId ?? '') : ''
output clientSecret string = createAppRegistration ? (appRegistrationScript.?properties.?outputs.?ClientSecret ?? '') : ''
output tenantId string = tenant().tenantId
output issuerUri string = 'https://sts.windows.net/${tenant().tenantId}/'

// Output configuration summary for verification
output configurationSummary object = createAppRegistration ? {
  applicationName: appDisplayName
  applicationId: appRegistrationScript.?properties.?outputs.?ApplicationId ?? ''
  redirectUris: [
    '${webAppUrl}/.auth/login/aad/callback'
    '${webAppUrl}/redirect'
  ]
  logoutUrl: '${webAppUrl}/.auth/logout'
  enterpriseAppSettings: {
    accountEnabled: true
    assignmentRequired: true
    visibleToUsers: true
  }
  clientSecretExpiry: appRegistrationScript.?properties.?outputs.?SecretExpiry ?? ''
  permissionsRequired: [
    'User.Read'
    'openid'
    'email'  
    'profile'
  ]
  postDeploymentSteps: [
    'Grant Admin Consent in Azure Portal (cannot be automated)'
    'Authentication is ready to use after admin consent'
  ]
  automationStatus: 'Fully automated except admin consent'
} : {
  automationStatus: 'Skipped - createAppRegistration set to false'
}
