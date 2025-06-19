# Update ARM Template for Deploy to Azure Button

This document explains how to update the Azure Blob Storage with the latest ARM templates for the "Deploy to Azure" button.

## Prerequisites

- Azure CLI installed and logged in, or Azure PowerShell installed and connected
- Appropriate permissions to the storage account

## Recommended Method: Using the Template Hosting Setup Scripts

We've created dedicated scripts to handle the entire process including CORS configuration:

### PowerShell

```powershell
# Navigate to project root
# Run the script
./scripts/setup_template_hosting.ps1 -resourceGroupName "YourResourceGroup" -storageAccountName "yourstorageaccount"
```

### Bash

```bash
# Navigate to project root
# Make the script executable if needed
chmod +x ./scripts/setup_template_hosting.sh
# Run the script
./scripts/setup_template_hosting.sh YourResourceGroup yourstorageaccount
```

These scripts will:
- Upload both deployment.json and createUiDefinition.json to the storage account
- Configure CORS settings to allow access from Azure Portal
- Generate the final deployment URL for your "Deploy to Azure" button

For more details, see [Template Hosting Setup](./docs/template_hosting_setup.md).

## Legacy Method: Manual Upload (deployment.json only)

The following is the legacy approach which only uploads the deployment.json file:

```bash
# Login to Azure if not already logged in
az login

# Set variables
STORAGE_ACCOUNT="stbtpukssandopenai"
CONTAINER_NAME="policing-assistant-azure-deployment-template"
TEMPLATE_FILE="infrastructure/deployment.json"
BLOB_NAME="deployment.json"

# Upload the template file
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --name $BLOB_NAME \
  --file $TEMPLATE_FILE \
  --auth-mode login \
  --overwrite

# Generate a SAS token with 1 year expiry
END_DATE=$(date -u -d "1 year" '+%Y-%m-%dT%H:%M:%SZ')
SAS_TOKEN=$(az storage blob generate-sas \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --name $BLOB_NAME \
  --permissions r \
  --expiry $END_DATE \
  --https-only \
  --output tsv)

# Generate the full URL
BLOB_URL=$(az storage blob url \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER_NAME \
  --name $BLOB_NAME \
  --output tsv)

# Print the full URL with SAS token
FULL_URL="${BLOB_URL}?${SAS_TOKEN}"
echo "ARM Template URL with SAS: $FULL_URL"

# URL encode for the deploy button
ENCODED_URL=$(echo $FULL_URL | sed 's/:/\%3A/g' | sed 's/\//\%2F/g' | sed 's/=/\%3D/g' | sed 's/\?/\%3F/g' | sed 's/+/\%2B/g' | sed 's/&/\%26/g')

# Print the deploy button markdown
DEPLOY_BUTTON="[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/$ENCODED_URL)"
echo "Deploy button markdown: $DEPLOY_BUTTON"
```

### Important Note About One-Click Deployment

The legacy method only uploads the deployment.json file and doesn't address CORS issues with createUiDefinition.json. For a true one-click deployment experience with custom UI, use the recommended method with the template hosting setup scripts.

## Troubleshooting CORS Issues

If you're experiencing CORS errors when users click the deployment button, ensure:

1. Both deployment.json and createUiDefinition.json are uploaded to the storage account
2. CORS is properly configured on the storage account to allow requests from portal.azure.com
3. The storage container has blob public access enabled
4. Your deployment URL includes both the deployment template and UI definition template

You can test CORS configuration with:

```bash
curl -X OPTIONS <your-blob-url> -H 'Origin: https://portal.azure.com' -I
```

The response should include headers like `Access-Control-Allow-Origin: *` or specifically allow portal.azure.com.

## Creating a Complete One-Click Deployment Link

For a proper one-click deployment with a custom UI, you'll need a URL with both the deployment template and UI definition template:

```
https://portal.azure.com/#create/Microsoft.Template/uri/<encoded-deployment-url>/createUIDefinitionUri/<encoded-createui-url>
```

The setup scripts will generate this URL for you automatically.
