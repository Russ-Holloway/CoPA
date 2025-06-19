# Upload UI Definition and Generate Deployment URL
# This script uploads the createUiDefinition.json file to your existing storage account
# and generates a new deployment URL using your storage account files

# Fill in these variables with your existing storage account details
$resourceGroup = "rg-btp-prod-sand-openai"  # Your resource group
$storageAccount = "stbtpukssandopenai"  # Your storage account name
$containerName = "policing-assistant-azure-deployment-template"  # Your container name

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

# Upload template files to the existing container
Write-Host "Uploading createUiDefinition.json to storage..." -ForegroundColor Yellow
Set-AzStorageBlobContent -File "infrastructure\createUiDefinition.json" -Container $containerName -Blob "createUiDefinition.json" -Context (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount).Context -Force -Properties @{"ContentType" = "application/json"}

Write-Host "Uploading deployment.json to storage..." -ForegroundColor Yellow
Set-AzStorageBlobContent -File "infrastructure\deployment.json" -Container $containerName -Blob "deployment.json" -Context (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount).Context -Force -Properties @{"ContentType" = "application/json"}

# Generate deployment URL
$blobEndpoint = (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount).PrimaryEndpoints.Blob.TrimEnd('/')
$deploymentUrl = "$blobEndpoint/$containerName/deployment.json"
$createUiDefinitionUrl = "$blobEndpoint/$containerName/createUiDefinition.json"

$encodedDeploymentUrl = [System.Web.HttpUtility]::UrlEncode($deploymentUrl)
$encodedCreateUiDefinitionUrl = [System.Web.HttpUtility]::UrlEncode($createUiDefinitionUrl)

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
