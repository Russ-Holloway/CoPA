# Update this with your resource group and storage account names
$resourceGroup = "YourResourceGroupName"
$storageAccount = "YourStorageAccountName"

# Run the template hosting setup script
$scriptPath = Join-Path (Get-Location).Path "scripts\setup_template_hosting.ps1"
& $scriptPath -resourceGroupName $resourceGroup -storageAccountName $storageAccount
