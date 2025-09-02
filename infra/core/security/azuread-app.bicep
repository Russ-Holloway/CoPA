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

# Connect using managed identity
Connect-AzAccount -Identity
Write-Output "Successfully connected to Azure using managed identity"

# Get access token for Microsoft Graph API
$context = Get-AzContext
$tokenResponse = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com/"
$accessToken = $tokenResponse.Token
Write-Output "Successfully obtained access token for Microsoft Graph"

# Define headers for REST API calls
$headers = @{
    'Authorization' = "Bearer $accessToken"
    'Content-Type' = 'application/json'
}

# Define redirect URIs
$redirectUris = @(
    "$WebAppUrl/.auth/login/aad/callback",
    "$WebAppUrl/redirect"
)

$logoutUrl = "$WebAppUrl/.auth/logout"

# Check if app already exists using REST API
$filterUrl = "https://graph.microsoft.com/v1.0/applications?`$filter=displayName eq '$AppDisplayName'"
try {
    $existingAppsResponse = Invoke-RestMethod -Uri $filterUrl -Headers $headers -Method GET
    $existingApp = $existingAppsResponse.value | Select-Object -First 1
} catch {
    Write-Output "Error checking for existing app: $($_.Exception.Message)"
    $existingApp = $null
}

if ($existingApp) {
    Write-Output "App registration '$AppDisplayName' already exists. Using existing app."
    $app = $existingApp
} else {
    Write-Output "Creating new app registration: $AppDisplayName"
    
    # Create app registration using REST API
    $appBody = @{
        displayName = $AppDisplayName
        signInAudience = "AzureADMyOrg"
        web = @{
            redirectUris = $redirectUris
            logoutUrl = $logoutUrl
            implicitGrantSettings = @{
                enableIdTokenIssuance = $true
                enableAccessTokenIssuance = $false
            }
        }
        requiredResourceAccess = @(
            @{
                resourceAppId = "00000003-0000-0000-c000-000000000000"  # Microsoft Graph
                resourceAccess = @(
                    @{
                        id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"  # User.Read
                        type = "Scope"
                    },
                    @{
                        id = "37f7f235-527c-4136-accd-4a02d197296e"  # openid
                        type = "Scope"
                    },
                    @{
                        id = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"  # email
                        type = "Scope"
                    },
                    @{
                        id = "14dad69e-099b-42c9-810b-d002981feec1"  # profile
                        type = "Scope"
                    }
                )
            }
        )
    }
    
    $appBodyJson = $appBody | ConvertTo-Json -Depth 10
    $createAppUrl = "https://graph.microsoft.com/v1.0/applications"
    
    try {
        $app = Invoke-RestMethod -Uri $createAppUrl -Headers $headers -Method POST -Body $appBodyJson
        Write-Output "Successfully created app registration with ID: $($app.id)"
    } catch {
        Write-Output "Error creating app registration: $($_.Exception.Message)"
        throw "Failed to create Azure AD app registration"
    }
}

# Create or get service principal (Enterprise Application)
$servicePrincipalUrl = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$($app.appId)'"
try {
    $servicePrincipalResponse = Invoke-RestMethod -Uri $servicePrincipalUrl -Headers $headers -Method GET
    $servicePrincipal = $servicePrincipalResponse.value | Select-Object -First 1
} catch {
    Write-Output "Error checking for existing service principal: $($_.Exception.Message)"
    $servicePrincipal = $null
}

if (-not $servicePrincipal) {
    Write-Output "Creating service principal (Enterprise Application)"
    $spBody = @{
        appId = $app.appId
        accountEnabled = $true
        appRoleAssignmentRequired = $true
    }
    $spBodyJson = $spBody | ConvertTo-Json -Depth 10
    $createSpUrl = "https://graph.microsoft.com/v1.0/servicePrincipals"
    
    try {
        $servicePrincipal = Invoke-RestMethod -Uri $createSpUrl -Headers $headers -Method POST -Body $spBodyJson
        Write-Output "Successfully created service principal with ID: $($servicePrincipal.id)"
    } catch {
        Write-Output "Error creating service principal: $($_.Exception.Message)"
        throw "Failed to create service principal"
    }
} else {
    Write-Output "Service principal already exists. Updating settings."
    $updateSpBody = @{
        accountEnabled = $true
        appRoleAssignmentRequired = $true
    }
    $updateSpBodyJson = $updateSpBody | ConvertTo-Json -Depth 10
    $updateSpUrl = "https://graph.microsoft.com/v1.0/servicePrincipals/$($servicePrincipal.id)"
    
    try {
        Invoke-RestMethod -Uri $updateSpUrl -Headers $headers -Method PATCH -Body $updateSpBodyJson
        Write-Output "Successfully updated service principal settings"
    } catch {
        Write-Output "Warning: Could not update service principal settings: $($_.Exception.Message)"
    }
}

# Create client secret
$secretName = "CoPPA-Deployment-Secret-$(Get-Date -Format 'yyyyMMdd')"
$secretEnd = (Get-Date).AddMonths($ClientSecretExpirationMonths).ToString("yyyy-MM-ddTHH:mm:ssZ")

$secretBody = @{
    passwordCredential = @{
        displayName = $secretName
        endDateTime = $secretEnd
    }
}
$secretBodyJson = $secretBody | ConvertTo-Json -Depth 10
$addSecretUrl = "https://graph.microsoft.com/v1.0/applications/$($app.id)/addPassword"

try {
    $secretResponse = Invoke-RestMethod -Uri $addSecretUrl -Headers $headers -Method POST -Body $secretBodyJson
    $secret = $secretResponse
    Write-Output "Successfully created client secret"
} catch {
    Write-Output "Error creating client secret: $($_.Exception.Message)"
    throw "Failed to create client secret"
}

# Set outputs for ARM template (required for deployment script outputs)
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['ApplicationId'] = $app.appId
$DeploymentScriptOutputs['ServicePrincipalId'] = $servicePrincipal.id  
$DeploymentScriptOutputs['ClientSecret'] = $secret.secretText
$DeploymentScriptOutputs['SecretExpiry'] = $secretEnd.Substring(0,10)  # Extract date part

# Also output results for logging
$result = @{
    ApplicationId = $app.appId
    ApplicationObjectId = $app.id
    ServicePrincipalId = $servicePrincipal.id
    ClientSecret = $secret.secretText
    TenantId = $context.Tenant.Id
    RedirectUris = $redirectUris
    LogoutUrl = $logoutUrl
    SecretExpiry = $secretEnd.Substring(0,10)  # Extract date part
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
