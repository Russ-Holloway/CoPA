# Fix CORS for Azure Deployment Button
# This script fixes the CORS issue for the "Deploy to Azure" button by:
# 1. Creating a storage account with CORS enabled
# 2. Uploading the template files to the storage account
# 3. Generating a deployment URL that uses the storage account instead of GitHub

# Parameters - update these with your values
$resourceGroup = "PoliceAssistantResources"
$storageAccount = "policeassisttemplate"
$location = "westeurope" # Change to your preferred Azure region
$containerName = "templates"

# Install Az module if not already installed
if (-not (Get-Module -ListAvailable -Name Az.Storage)) {
    Write-Host "Installing Az.Storage module..."
    Install-Module -Name Az.Storage -Force -Scope CurrentUser
}

# Login to Azure
Write-Host "Checking Azure login..."
try {
    $azContext = Get-AzContext -ErrorAction Stop
    if (-not $azContext) {
        throw "Not logged in"
    }
    Write-Host "Already logged in as $($azContext.Account)" -ForegroundColor Green
}
catch {
    Write-Host "Please login to Azure..."
    Connect-AzAccount
}

# Create resource group if it doesn't exist
$rgExists = Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue
if (-not $rgExists) {
    Write-Host "Creating resource group '$resourceGroup' in location '$location'..."
    New-AzResourceGroup -Name $resourceGroup -Location $location
}

# Create storage account if it doesn't exist
$storageAccountExists = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount -ErrorAction SilentlyContinue
if (-not $storageAccountExists) {
    Write-Host "Creating storage account '$storageAccount'..."
    New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount -Location $location -SkuName Standard_LRS -Kind StorageV2
}

# Get storage account context
$storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount
$ctx = $storageAccount.Context

# Create container with public access
$container = Get-AzStorageContainer -Name $containerName -Context $ctx -ErrorAction SilentlyContinue
if (-not $container) {
    Write-Host "Creating container '$containerName' with Blob public access..."
    New-AzStorageContainer -Name $containerName -Context $ctx -Permission Blob
} else {
    # Ensure container has Blob (public) access
    Set-AzStorageContainerAcl -Name $containerName -Context $ctx -Permission Blob
    Write-Host "Container '$containerName' already exists, set permission to Blob (public)"
}

# Set CORS rules for Azure Portal
Write-Host "Configuring CORS settings for Azure Portal..."
$corsRules = @(
    @{
        AllowedOrigins = @("https://portal.azure.com", "https://ms.portal.azure.com", "https://*.portal.azure.com", 
                          "https://portal.azure.us", "https://*.portal.azure.us", 
                          "https://portal.azure.cn", "https://*.portal.azure.cn");
        AllowedMethods = @("GET", "HEAD", "OPTIONS", "PUT", "POST");
        AllowedHeaders = @("*");
        ExposedHeaders = @("*");
        MaxAgeInSeconds = 3600;
    },
    @{
        AllowedOrigins = @("https://afd.hosting.portal.azure.net", "https://afd.hosting-ms.portal.azure.com", 
                          "https://*.afd.hosting.portal.azure.net", "https://management.azure.com");
        AllowedMethods = @("GET", "HEAD", "OPTIONS", "PUT", "POST");
        AllowedHeaders = @("*");
        ExposedHeaders = @("*");
        MaxAgeInSeconds = 3600;
    },
    @{
        AllowedOrigins = @("*");
        AllowedMethods = @("GET", "HEAD", "OPTIONS");
        AllowedHeaders = @("*");
        ExposedHeaders = @("*");
        MaxAgeInSeconds = 3600;
    }
)
Set-AzStorageCORSRule -ServiceType Blob -CorsRules $corsRules -Context $ctx

# Path to template files
$createUiDefinitionPath = Join-Path (Get-Location).Path "infrastructure\createUiDefinition.json"
$deploymentPath = Join-Path (Get-Location).Path "infrastructure\deployment.json"

# Upload template files to storage
Write-Host "Uploading template files to storage..."
Set-AzStorageBlobContent -File $createUiDefinitionPath -Container $containerName -Blob "createUiDefinition.json" -Context $ctx -Force -Properties @{"ContentType" = "application/json"}
Set-AzStorageBlobContent -File $deploymentPath -Container $containerName -Blob "deployment.json" -Context $ctx -Force -Properties @{"ContentType" = "application/json"}

# Get the URLs for the uploaded files
$createUiDefinitionUrl = $ctx.BlobEndPoint + "$containerName/createUiDefinition.json"
$deploymentUrl = $ctx.BlobEndPoint + "$containerName/deployment.json"

# Encode the URLs for the deployment link
$encodedCreateUiUrl = [System.Web.HttpUtility]::UrlEncode($createUiDefinitionUrl)
$encodedTemplateUrl = [System.Web.HttpUtility]::UrlEncode($deploymentUrl)

# Generate the Azure Portal deployment URL
$portalUrl = "https://portal.azure.com/#create/Microsoft.Template/uri/$encodedTemplateUrl/createUIDefinitionUri/$encodedCreateUiUrl"

Write-Host "==========================================================================================" -ForegroundColor Cyan
Write-Host "Your 'Deploy to Azure' button URL is:" -ForegroundColor Green
Write-Host $portalUrl -ForegroundColor Yellow
Write-Host "==========================================================================================" -ForegroundColor Cyan
Write-Host "To use this URL in your README.md, update your deployment button with this Markdown:"
Write-Host "[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]($portalUrl)" -ForegroundColor Yellow
Write-Host "==========================================================================================" -ForegroundColor Cyan
Write-Host "Testing direct access to template files..."

try {
    Invoke-WebRequest -Uri $createUiDefinitionUrl -Method GET -ErrorAction Stop | Out-Null
    Write-Host "✓ createUiDefinition.json is publicly accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ createUiDefinition.json is NOT accessible: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Invoke-WebRequest -Uri $deploymentUrl -Method GET -ErrorAction Stop | Out-Null
    Write-Host "✓ deployment.json is publicly accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ deployment.json is NOT accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test CORS
Write-Host "==========================================================================================" -ForegroundColor Cyan
Write-Host "CORS Testing Commands (run these manually if needed):" -ForegroundColor Yellow
Write-Host "Invoke-WebRequest -Uri $deploymentUrl -Method OPTIONS -Headers @{'Origin'='https://portal.azure.com'; 'Access-Control-Request-Method'='GET'}"
Write-Host "Invoke-WebRequest -Uri $createUiDefinitionUrl -Method OPTIONS -Headers @{'Origin'='https://portal.azure.com'; 'Access-Control-Request-Method'='GET'}"
Write-Host "==========================================================================================" -ForegroundColor Cyan

# Save the URL to a file for later reference
$portalUrl | Out-File -FilePath "azure_deployment_url.txt"
Write-Host "The deployment URL has been saved to 'azure_deployment_url.txt'"
