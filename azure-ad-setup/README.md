# Azure AD Setup Web App Deployment

This directory contains a simple web interface for completing Azure AD app registration after the main CoPA deployment.

## Deployment Options

### Option 1: Azure Static Web Apps (Recommended)

Deploy this as an Azure Static Web App for easy hosting:

```bash
# Create a static web app
az staticwebapp create \
  --name "coppa-azure-ad-setup" \
  --resource-group "your-resource-group" \
  --source "https://github.com/your-org/CoPA" \
  --branch "main" \
  --app-location "/azure-ad-setup" \
  --location "Central US"
```

### Option 2: GitHub Pages

1. Push this directory to a GitHub repository
2. Enable GitHub Pages in repository settings
3. Use the resulting URL in your deployment template

### Option 3: Local Hosting

For development or testing:

```bash
# Serve locally with Python
cd azure-ad-setup
python -m http.server 8000

# Or with Node.js
npx serve .
```

## Usage

The web app expects these URL parameters:
- `displayName` - Azure AD app display name
- `supportedAccountTypes` - Account type support
- `enableImplicitFlow` - Enable implicit flow
- `enableUserRead` - Enable User.Read permission
- `enableGroupRead` - Enable Group.Read.All permission
- `clientSecretDescription` - Client secret description
- `clientSecretExpiry` - Secret expiry in months
- `webAppUrl` - CoPA web app URL
- `tenantId` - Azure tenant ID
- `userAssignmentRequired` - Require user assignment
- `subscriptionId` - Azure subscription ID
- `resourceGroupName` - Resource group name
- `webAppName` - Web app name

These parameters are automatically populated by the ARM template output URL.

## Security Note

This setup interface provides manual instructions for creating the Azure AD app registration. In a production environment, you might want to implement actual Microsoft Graph API integration for automated setup, but this requires careful handling of authentication and permissions.
