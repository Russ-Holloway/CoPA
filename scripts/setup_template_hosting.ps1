param(
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$storageAccountName,
    
    [Parameter(Mandatory = $false)]
    [string]$containerName = "templates"
)

# Check if Azure PowerShell is installed, install if missing
if (-not (Get-Module -ListAvailable -Name Az)) {
    Write-Host "Azure PowerShell module not found. Installing..."
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force -AllowClobber
}

# Check if logged in to Azure
try {
    $context = Get-AzContext -ErrorAction Stop
    if (-not $context) { throw }
} catch {
    Write-Host "Not logged in to Azure. Please login..."
    Connect-AzAccount
}

# Add System.Web assembly for URL encoding
Add-Type -AssemblyName System.Web

# Get storage account context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue
if (-not $storageAccount) {
    Write-Error "Storage account '$storageAccountName' not found in resource group '$resourceGroupName'. Please check the account name and resource group."
    exit 1
}
$ctx = $storageAccount.Context

# Verify the container exists
$container = Get-AzStorageContainer -Name $containerName -Context $ctx -ErrorAction SilentlyContinue
if (!$container) {
    Write-Host "Container '$containerName' not found. Creating new container."
    New-AzStorageContainer -Name $containerName -Context $ctx -Permission Blob
}

# Verify CORS is set properly
Write-Host "Checking CORS settings..."
$corsRules = Get-AzStorageCORSRule -ServiceType Blob -Context $ctx
if (!$corsRules -or ($corsRules.AllowedOrigins -notcontains "*")) {
    Write-Host "Configuring CORS settings for the storage account to allow all origins"
    $corsRules = (@{
        AllowedOrigins = @("*");
        AllowedMethods = @("GET", "HEAD", "OPTIONS");
        AllowedHeaders = @("*");
        ExposedHeaders = @("*");
        MaxAgeInSeconds = 3600;
    })
    Set-AzStorageCORSRule -ServiceType Blob -CorsRules $corsRules -Context $ctx
}

# Path to createUiDefinition.json file
$createUiDefinitionJsonPath = Join-Path (Get-Location).Path "infrastructure/createUiDefinition.json"

# Upload createUiDefinition.json to the container
Write-Host "Uploading createUiDefinition.json to the container"
Set-AzStorageBlobContent -File $createUiDefinitionJsonPath `
    -Container $containerName `
    -Blob "createUiDefinition.json" `
    -Context $ctx `
    -Properties @{"ContentType" = "application/json"} `
    -Force

# Check if deployment.json exists in the container
$deploymentBlob = Get-AzStorageBlob -Container $containerName -Blob "deployment.json" -Context $ctx -ErrorAction SilentlyContinue
if (!$deploymentBlob) {
    Write-Host "deployment.json not found in container. Uploading..."
    $deploymentJsonPath = Join-Path (Get-Location).Path "infrastructure/deployment.json"
    Set-AzStorageBlobContent -File $deploymentJsonPath `
        -Container $containerName `
        -Blob "deployment.json" `
        -Context $ctx `
        -Properties @{"ContentType" = "application/json"} `
        -Force
}

# Output template URLs
$deploymentUrl = $ctx.BlobEndPoint + "$containerName/deployment.json"
$createUiDefinitionUrl = $ctx.BlobEndPoint + "$containerName/createUiDefinition.json"

Write-Host "Template URLs:"
Write-Host "Deployment Template URL: $deploymentUrl"
Write-Host "Create UI Definition URL: $createUiDefinitionUrl"

# Output the Azure Portal deployment link
$encodedCreateUiDefinitionUrl = [System.Web.HttpUtility]::UrlEncode($createUiDefinitionUrl)
$encodedDeploymentUrl = [System.Web.HttpUtility]::UrlEncode($deploymentUrl)
$portalUrl = "https://portal.azure.com/#create/Microsoft.Template/uri/$encodedDeploymentUrl/createUIDefinitionUri/$encodedCreateUiDefinitionUrl"

Write-Host "-----------------------------------------------------------"
Write-Host "Azure Portal Deployment URL (Copy this for one-click deployment):"
Write-Host $portalUrl
Write-Host "-----------------------------------------------------------"

Write-Host "To test if the files are accessible and CORS is working correctly, run:"
Write-Host "Invoke-WebRequest -Uri $createUiDefinitionUrl -Method OPTIONS -Headers @{'Origin'='https://portal.azure.com'}"
