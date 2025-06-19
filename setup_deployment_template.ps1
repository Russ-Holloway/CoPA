# Update this with your resource group and storage account names
# IMPORTANT: Make sure this resource group exists or will be created
# The storage account name must be globally unique (only lowercase letters and numbers, 3-24 characters)
$resourceGroup = "rg-btp-prod-sand-openai"
$storageAccount = "stbtpukssandopenai"
$location = "uksouth" # Change to your preferred Azure region

# Create resource group if it doesn't exist
$rgExists = az group exists --name $resourceGroup | ConvertFrom-Json
if (-not $rgExists) {
    Write-Host "Creating resource group '$resourceGroup' in location '$location'..."
    az group create --name $resourceGroup --location $location
}

# Check if storage account exists, create if it doesn't
$storageExists = az storage account check-name --name $storageAccount | ConvertFrom-Json
if ($storageExists.nameAvailable) {
    Write-Host "Creating storage account '$storageAccount' in resource group '$resourceGroup'..."
    az storage account create --name $storageAccount --resource-group $resourceGroup --location $location --sku Standard_LRS --kind StorageV2
}

# Run the template hosting setup script
$scriptPath = Join-Path (Get-Location).Path "scripts\setup_template_hosting.ps1"
& $scriptPath -resourceGroupName $resourceGroup -storageAccountName $storageAccount
