# Quick Fix for "Deploy to Azure" Button CORS Error

## The Problem

When users click the "Deploy to Azure" button, they see CORS errors:

```
There was an error downloading the template from URI 'https://raw.githubusercontent.com/Russ-Holloway/Policing-Assistant/main/infrastructure/deployment.json'. 
Ensure that the template is publicly accessible and that the publisher has enabled CORS policy on the endpoint.

There was an error downloading from URI 'https://raw.githubusercontent.com/Russ-Holloway/Policing-Assistant/main/infrastructure/createUiDefinition.json'.
```

This happens because GitHub's raw content URLs don't support the CORS headers required by the Azure Portal.

## The Solution

We need to host the template files in Azure Blob Storage, which supports CORS, and then update the deployment button URL to point to these files.

## How to Fix (Quick Method)

### Windows Users

1. Double-click on `fix_cors_deployment.cmd` to run the script
2. Follow the on-screen prompts (you'll need to sign in to Azure if not already signed in)
3. When the script completes, it will display and save the new deployment URL
4. Update your README.md's "Deploy to Azure" button with this new URL

### PowerShell Users

1. Open PowerShell with administrator privileges
2. Navigate to the repository directory
3. Run: `.\fix_cors_deployment.ps1`
4. Follow the on-screen prompts
5. Update your README.md with the generated deployment URL

## Verifying the Fix

After running the script, test your deployment by:

1. Opening the generated URL in a new browser tab
2. Ensuring the Azure Portal deployment page loads correctly
3. Confirming that both the deployment.json and createUiDefinition.json files are properly displayed

## Troubleshooting

If issues persist:

1. Verify your Azure storage account has public blob access enabled
2. Confirm CORS settings are correctly applied (the script should handle this)
3. Try accessing the template URLs directly in your browser to ensure they're accessible
4. Clear your browser cache or try from an incognito/private browser window
5. If using a custom domain for your storage account, ensure SSL is properly configured

## What This Script Does

1. Creates or uses an existing resource group and storage account
2. Creates a blob container with public access
3. Configures proper CORS settings for Azure Portal
4. Uploads the template files with the correct content type
5. Generates a deployment URL that points to these files
6. Tests access to the files
7. Saves the URL for later use
