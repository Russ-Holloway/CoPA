# Azure AD Post-Deployment Setup

## Overview

The CoPA deployment now uses a post-deployment approach for Azure AD app registration setup. This approach was implemented to resolve issues with deployment script sandbox limitations that prevented interactive authentication flows.

## How It Works

1. **Infrastructure Deployment**: The ARM template deploys all Azure resources (App Service, Cosmos DB, etc.) without Azure AD configuration
2. **Post-Deployment Setup**: After deployment completes, users click a provided URL to complete Azure AD setup interactively
3. **Browser-Based Authentication**: The setup process runs in the browser context where interactive consent flows work properly

## Deployment Flow

### Step 1: Deploy Infrastructure
Deploy using the ARM template as usual. The `CreateAzureAdAppRegistration` parameter controls whether Azure AD setup is needed:

```bash
az deployment group create \
  --resource-group your-rg \
  --template-file deployment.json \
  --parameters @parameters.json
```

### Step 2: Complete Azure AD Setup
If `CreateAzureAdAppRegistration` was set to `true`, the deployment outputs include an `azureAdSetupUrl`. Click this URL to complete the setup:

1. Review the Azure AD configuration parameters
2. Follow the manual setup instructions provided
3. Create the Azure AD app registration using Azure CLI commands
4. Update the CoPA app settings with the new values

## Setup Web Interface

The Azure AD setup interface is located in `/azure-ad-setup/` and provides:

- **Parameter Review**: Shows all Azure AD configuration options from the createUiDefinition
- **Step-by-Step Instructions**: Provides Azure CLI commands for creating the app registration
- **Automated Commands**: Pre-populated with your specific values for copy-paste execution

## Deployment Options for Setup Interface

### Option 1: GitHub Pages (Recommended)
1. Push the `/azure-ad-setup/` directory to your GitHub repository
2. Enable GitHub Pages in repository settings
3. Update the `azureAdSetupUrl` in `deployment.json` to use your GitHub Pages URL

### Option 2: Azure Static Web Apps
Deploy the setup interface as a separate Static Web App:

```bash
az staticwebapp create \
  --name "coppa-azure-ad-setup" \
  --resource-group "your-resource-group" \
  --source "https://github.com/your-org/CoPA" \
  --branch "main" \
  --app-location "/azure-ad-setup"
```

### Option 3: Local Development
For testing:

```bash
cd azure-ad-setup
python -m http.server 8000
```

## Benefits of This Approach

1. **No Sandbox Limitations**: Runs in browser context where interactive auth works
2. **Better User Experience**: Clear step-by-step process with visual feedback
3. **Flexible Deployment**: Setup interface can be hosted anywhere
4. **Enhanced Security**: No deployment script privileges required
5. **Better Error Handling**: Users can retry steps if needed

## Security Considerations

- The setup interface shows configuration parameters but doesn't handle secrets
- All Azure AD operations are performed by the user with their own credentials
- Client secrets are generated and managed through Azure CLI
- No sensitive data is transmitted through the web interface

## Troubleshooting

### Common Issues

1. **Setup URL doesn't work**: Update the `azureAdSetupUrl` in deployment.json with your actual hosting URL
2. **Permission errors**: Ensure you have Global Administrator or Application Administrator privileges
3. **CLI commands fail**: Make sure you're logged into Azure CLI with the correct account

### Manual Setup

If the web interface isn't available, you can perform the Azure AD setup manually using the Azure Portal:

1. Go to Azure Portal → Azure Active Directory → App registrations
2. Create a new registration with the parameters from your deployment
3. Configure redirect URIs, permissions, and client secrets
4. Update your CoPA app settings with the new values

## Migration from Previous Approach

The new approach is backward compatible. Existing deployments with working deployment scripts will continue to function. New deployments will use the post-deployment setup approach when `CreateAzureAdAppRegistration` is enabled.
