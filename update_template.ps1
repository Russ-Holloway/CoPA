# Update deployment template script
# This script updates the deployment.json and createUiDefinition.json files in your Azure storage account

# Parameters - Fill in with your values from fix_cors_deployment.ps1
$resourceGroup = "PoliceAssistantResources"
$storageAccount = "policeassisttemplate" 
$containerName = "templates"

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

# Get storage account context
$storageAcct = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccount -ErrorAction SilentlyContinue
if (-not $storageAcct) {
    Write-Error "Storage account '$storageAccount' not found in resource group '$resourceGroup'. Please check your settings."
    exit 1
}

$ctx = $storageAcct.Context
Write-Host "Connected to storage account: $storageAccount" -ForegroundColor Green

# Upload the template files
$deploymentJsonPath = Join-Path $PSScriptRoot "infrastructure\deployment.json"
$uiDefinitionJsonPath = Join-Path $PSScriptRoot "infrastructure\createUiDefinition.json"

Write-Host "Uploading deployment.json to blob storage..."
Set-AzStorageBlobContent -File $deploymentJsonPath -Container $containerName -Blob "deployment.json" -Context $ctx -Force | Out-Null

Write-Host "Uploading createUiDefinition.json to blob storage..."
Set-AzStorageBlobContent -File $uiDefinitionJsonPath -Container $containerName -Blob "createUiDefinition.json" -Context $ctx -Force | Out-Null

Write-Host "Files uploaded successfully!" -ForegroundColor Green

# Generate container SAS token with read permission
$endTime = (Get-Date).AddYears(1)
$containerSAS = New-AzStorageContainerSASToken -Container $containerName -Permission r -ExpiryTime $endTime -Context $ctx

# Generate URLs with container SAS token
$containerUrl = "https://$storageAccount.blob.core.windows.net/$containerName$containerSAS"
$deploymentUrl = "$containerUrl/deployment.json"
$uiDefinitionUrl = "$containerUrl/createUiDefinition.json"

# URL encode for Azure deployment button
$encodedDeployUrl = [System.Web.HttpUtility]::UrlEncode($deploymentUrl)
$encodedUiUrl = [System.Web.HttpUtility]::UrlEncode($uiDefinitionUrl)

# Build the deploy to Azure URL
$azureDeployUrl = "https://portal.azure.com/#create/Microsoft.Template/uri/$encodedDeployUrl/createUIDefinitionUri/$encodedUiUrl"

Write-Host "Your new 'Deploy to Azure' button URL is:" -ForegroundColor Cyan
Write-Host $azureDeployUrl -ForegroundColor Yellow

# Save to a file for easy access
$azureDeployUrl | Out-File -FilePath (Join-Path $PSScriptRoot "deployButtonUrl.txt") -Force
Write-Host "URL also saved to deployButtonUrl.txt" -ForegroundColor Green

Write-Host "`nTo update your README.md, replace your current 'Deploy to Azure' button with:" -ForegroundColor Cyan
Write-Host "[![Deploy to Azure](https://aka.ms/deploytoazurebutton)]($azureDeployUrl)" -ForegroundColor Yellow
