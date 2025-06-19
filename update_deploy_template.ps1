# Upload UI Definition and Generate Deployment URL
# This script uploads the createUiDefinition.json file to your existing storage account
# and generates a new deployment URL using your storage account files

# Fill in these variables with your existing storage account details
$resourceGroup = "YourResourceGroupName"  # The resource group containing your storage account
$storageAccount = "YourStorageAccountName"  # Your existing storage account name
$containerName = "YourContainerName"  # Your existing container name

# Check if Az.Storage module is installed
if (-not (Get-Module -ListAvailable -Name Az.Storage)) {
    Write-Host "Installing Az.Storage module..."
    Install-Module -Name Az.Storage -Force -Scope CurrentUser
}

# Check if System.Web is loaded (needed for URL encoding)
Add-Type -AssemblyName System.Web

# Connect to Azure if not already connected
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

# Get storage account context
$storageAcct = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount -ErrorAction SilentlyContinue
if (-not $storageAcct) {
    Write-Error "Storage account '$storageAccount' not found in resource group '$resourceGroup'. Please check your settings."
    exit 1
}

$ctx = $storageAcct.Context
Write-Host "Connected to storage account: $storageAccount" -ForegroundColor Green

# Verify the container exists
$container = Get-AzStorageContainer -Name $containerName -Context $ctx -ErrorAction SilentlyContinue
if (-not $container) {
    Write-Error "Container '$containerName' not found in storage account '$storageAccount'. Please check your settings."
    exit 1
}

Write-Host "Found container: $containerName" -ForegroundColor Green

# Path to createUiDefinition.json file
$createUiDefinitionPath = Join-Path (Get-Location).Path "infrastructure\createUiDefinition.json"

# Verify createUiDefinition.json exists
if (-not (Test-Path $createUiDefinitionPath)) {
    Write-Error "File not found: $createUiDefinitionPath"
    exit 1
}

# Upload createUiDefinition.json to the storage container
Write-Host "Uploading createUiDefinition.json to storage..." -ForegroundColor Yellow
Set-AzStorageBlobContent -File $createUiDefinitionPath -Container $containerName -Blob "createUiDefinition.json" -Context $ctx -Force -Properties @{"ContentType" = "application/json"}
Write-Host "Upload complete!" -ForegroundColor Green

# Check if deployment.json exists in the container
$deploymentExists = Get-AzStorageBlob -Container $containerName -Blob "deployment.json" -Context $ctx -ErrorAction SilentlyContinue
if (-not $deploymentExists) {
    Write-Host "Note: deployment.json not found in container. If you need to upload it, run:" -ForegroundColor Yellow
    Write-Host "Set-AzStorageBlobContent -File (Join-Path (Get-Location).Path 'infrastructure\deployment.json') -Container $containerName -Blob 'deployment.json' -Context `$ctx -Force -Properties @{'ContentType' = 'application/json'}" -ForegroundColor Cyan
}
else {
    Write-Host "Found existing deployment.json in container" -ForegroundColor Green
}

# Set CORS rules to ensure Azure Portal can access the files
Write-Host "Setting CORS rules for Azure Portal access..." -ForegroundColor Yellow
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
Write-Host "CORS rules updated successfully" -ForegroundColor Green

# Get URLs for the files
$deploymentUrl = $ctx.BlobEndPoint + "$containerName/deployment.json"
$createUiDefinitionUrl = $ctx.BlobEndPoint + "$containerName/createUiDefinition.json"

# URL encode the URLs
$encodedDeploymentUrl = [System.Web.HttpUtility]::UrlEncode($deploymentUrl)
$encodedCreateUiDefinitionUrl = [System.Web.HttpUtility]::UrlEncode($createUiDefinitionUrl)

# Generate the deployment URL
$portalDeployUrl = "https://portal.azure.com/#create/Microsoft.Template/uri/$encodedDeploymentUrl/createUIDefinitionUri/$encodedCreateUiDefinitionUrl"

# Output results
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Your template files are now hosted at:" -ForegroundColor Green
Write-Host "Deployment JSON: $deploymentUrl" -ForegroundColor Yellow
Write-Host "UI Definition: $createUiDefinitionUrl" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "Your Deploy to Azure button URL is:" -ForegroundColor Green
Write-Host $portalDeployUrl -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "To use this in your README.md, use this Markdown:" -ForegroundColor Green
Write-Host "[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]($portalDeployUrl)" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Cyan

# Save the URL to a file
$portalDeployUrl | Out-File -FilePath "azure_deploy_url.txt"
Write-Host "URL has been saved to azure_deploy_url.txt" -ForegroundColor Green

# Test file accessibility
Write-Host "Testing file accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $createUiDefinitionUrl -Method GET -ErrorAction Stop
    Write-Host "✓ createUiDefinition.json is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error accessing createUiDefinition.json: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $response = Invoke-WebRequest -Uri $deploymentUrl -Method GET -ErrorAction Stop
    Write-Host "✓ deployment.json is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
}
catch {
    Write-Host "✗ Error accessing deployment.json: $($_.Exception.Message)" -ForegroundColor Red
}
