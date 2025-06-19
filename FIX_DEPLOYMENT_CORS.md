# Fixing One-Click Deployment CORS Issues

This guide helps solve the CORS issue when trying to deploy your ARM templates directly from GitHub.

## The Issue

When users click the "Deploy to Azure" button, they encounter this error:

```
There was an error downloading the template from URI 'https://raw.githubusercontent.com/Russ-Holloway/Policing-Assistant/main/infrastructure/deployment.json'. Ensure that the template is publicly accessible and that the publisher has enabled CORS policy on the endpoint.

There was an error downloading from URI 'https://raw.githubusercontent.com/Russ-Holloway/Policing-Assistant/main/infrastructure/createUiDefinition.json'. Ensure that the template is publicly accessible and that the publisher has enabled CORS policy on the endpoint.
```

## The Solution

GitHub's raw content URLs don't have CORS headers enabled by default. The solution is to:

1. Host both template files in Azure Blob Storage (which supports CORS)
2. Configure the storage account to allow CORS requests from portal.azure.com
3. Generate a deployment link that references both files from Azure Storage

## Quick Setup

1. Edit the `setup_deployment_template.ps1` file to set your resource group and storage account names
2. Run the script in PowerShell:

```powershell
# Run as Administrator if needed
.\setup_deployment_template.ps1
```

3. The script will:
   - Install the Azure PowerShell module if not already installed
   - Sign you in to Azure if you're not already signed in
   - Upload both template files to your storage account
   - Configure CORS settings
   - Generate the final deployment URL

4. Use the generated URL for your "Deploy to Azure" button

## For More Information

See [Template Hosting Setup](./docs/template_hosting_setup.md) for detailed documentation.

## Troubleshooting

If you still encounter issues:

1. Make sure the storage container has public blob access enabled
2. Verify that CORS settings allow requests from portal.azure.com
3. Check that both files have the correct content type (application/json)
4. Test CORS using the provided test command in the script output
