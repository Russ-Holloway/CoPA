# CoPPA - College of Policing Assistant

**CoPPA (College of Policing Assistant)** is an advanced AI-powered Smart Assistant designed to enhance police decision-making and effectiveness. Built within a secure Microsoft Azure environment, this assistant integrates trusted data, policy, and user feedback to deliver actionable, transparent, and secure guidance.

---

## Table of Contents

- [Vision & Purpose](#vision--purpose)
- [Key Features](#key-features)
- [How It Works](#how-it-works)
- [Key Benefits](#key-benefits)
- [Screenshots](#screenshots)
- [Deployment](#deployment)
- [Quick Start](#quick-start)
- [Configure the App](#configure-the-app)
- [Authentication](#authentication)
- [App Configuration](#app-configuration)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [Community & Support](#community--support)
- [Trademarks](#trademarks)
- [Disclaimer](#disclaimer)

---

## Deployment

### PDS Compliant Deployment (For UK Police Forces)

**🚔 For all 44 UK Police Forces:** Use our PDS-compliant deployment that automatically generates resource names according to Police Digital Service standards.

[![Deploy PDS Compliant](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fyour-repo%2Finfrastructure%2Fdeployment.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fyour-repo%2Finfrastructure%2FcreateUiDefinition-pds.json)

📋 **[PDS Deployment Guide](docs/PDS-DEPLOYMENT-GUIDE.md)** - Complete guide for police forces  
📋 **[Azure Naming Guidelines](docs/azure-naming-guidelines.md)** - PDS naming conventions  

**Quick PDS Validation:**
```powershell
.\scripts\validate-pds-naming.ps1 -ForceCode "btp" -Environment "prod" -InstanceNumber "01"
```

### One-Click Azure Deployment

Click the button below to deploy directly to Azure with the correct GPT-4o model:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fstbtpukssandopenai.blob.core.windows.net%2Fpolicing-assistant-azure-deployment-template%2Fdeployment.json%3Fsp%3Dr%26st%3D2025-06-19T11%3A57%3A11Z%26se%3D2026-06-19T19%3A57%3A11Z%26spr%3Dhttps%26sv%3D2024-11-04%26sr%3Dc%26sig%3DQZ4ZQi9NqinJzhSNH69n9%252Fv9geabtrlXDaf86blN848%253D/createUIDefinitionUri/https%3A%2F%2Fstbtpukssandopenai.blob.core.windows.net%2Fpolicing-assistant-azure-deployment-template%2FcreateUiDefinition.json%3Fsp%3Dr%26st%3D2025-06-19T11%3A57%3A11Z%26se%3D2026-06-19T19%3A57%3A11Z%26spr%3Dhttps%26sv%3D2024-11-04%26sr%3Dc%26sig%3DQZ4ZQi9NqinJzhSNH69n9%252Fv9geabtrlXDaf86blN848%253D)

> **Note:** The deployment button provides a simple one-click experience. Just select your resource group (or create a new one), then click "Review + create" to deploy. All parameters are pre-configured for optimal performance with GPT-4o. No need to modify any parameters - the deployment uses the latest GPT-4o model with appropriate settings automatically.

### Post-Deployment Setup

After deployment completes, you only need to configure authentication. The search components are automatically set up during deployment.

#### Authentication Setup (Required)
**🚀 Quick Setup:** Run the automated authentication script:
```powershell
.\scripts\setup_azure_ad_auth.ps1 -WebAppName "your-web-app-name" -ResourceGroupName "your-resource-group"
```

**📋 Quick Reference:** [Azure AD Quick Reference](AZURE_AD_QUICK_REFERENCE.md)  
**📖 Full Guide:** [Azure AD Setup Guide](AZURE_AD_SETUP_GUIDE.md)

#### Search Components (Automatically Configured)
The Azure Cognitive Search components (index, data source, skillsets, and indexers) are automatically set up during deployment through a built-in deployment script. **No manual setup is required.**

If you need to troubleshoot or reconfigure search components:
```powershell
.\scripts\setup-search-components.ps1 -ResourceGroupName "your-resource-group-name" -SearchServiceName "your-search-service-name" -StorageAccountName "your-storage-account-name" -OpenAIServiceName "your-openai-service-name"
```

**📖 Full Guide:** [Search Components Setup Guide](docs/search_components_setup.md)

---

## Vision & Purpose

- **Improving Police Decision-Making:**  
  Supports officers with advice grounded in national/local policy, leveraging AI to process information from trusted sources such as the College of Policing, CPS Guidance, and local force policies.

- **Human in the Loop:**  
  Augments (but does not replace) human decision-making, supporting College of Policing’s four key areas: Criminal Justice, Investigations, Prevention, and Neighbourhood Policing.

---

## Key Features

- **Comprehensive Support:** Advice across Criminal Justice, Investigations, Prevention, and Neighbourhood Policing.
- **Transparency & Trust:** Every answer includes source citations.
- **Continuous Improvement:** Regular audits, user feedback, and daily data updates.
- **Security & Compliance:** Operates within a secure, compliant Azure environment.
- **Efficiency:** Fast, speech-enabled access to information.
- **Seamless Integration:** Works with local/national policies and Azure services.

---

## How It Works

- **Data Integration:**  
  Curated sources (e.g., College of Policing APP, CPS Guidance, Gov.uk) are indexed daily. Local force policies are managed centrally in Azure Storage.

- **AI Model:**  
  Runs securely on a Police Service Azure Tenant using a self-contained version of OpenAI, delivering human-like responses to technical, procedural, and legislative queries.

- **Interface:**  
  User-friendly chatbot/search interface, including speech-to-text for mobile efficiency.

- **Transparency:**  
  Every response includes references/citations for provenance and trust.

**Workflow Diagram:**  
*(Add a diagram here illustrating data flow from sources to the AI assistant and the user interface)*

---

## Key Benefits

- **Enhanced Decision-Making:** Reliable, up-to-date guidance from official sources.
- **Efficiency:** Quick access to advice, saving officer time.
- **Comprehensive Coverage:** Integrates both national and local information.
- **Transparency:** Citations and reminders in every response.
- **Continuous Improvement:** Daily data indexing and user-driven refinements.
- **Security:** Strong data protection and compliance with legal standards.

---

## Screenshots

> _Include screenshots or GIFs here to demonstrate the interface and functionality._

---

## Quick Start

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Russ-Holloway/CoPPA.git
   cd CoPPA
   ```

2. **Install Dependencies:**
   ```bash
   # Backend (Python)
   pip install -r requirements.txt

   # Frontend (TypeScript)
   cd frontend
   npm install
   npm run build
   ```

3. **Start the App:**
   - Use `start.cmd` or `start.sh` to build and launch both frontend and backend, or follow [Configure the App](#configure-the-app) for environment setup.

4. **Access the App:**
   - Open [http://127.0.0.1:50505](http://127.0.0.1:50505) in your browser.

---

## Configure the App

### Create a `.env` file

Follow instructions in the [App Settings](#app-settings) section to create a `.env` file for local development.

### Create a JSON file for Azure App Service

After creating your `.env` file, use provided PowerShell or Bash commands to generate a JSON file (`env.json`) for Azure App Service deployment.

---

## Authentication

### Quick Setup (Recommended)

After your Azure deployment completes, use our automated setup script:

```powershell
# Navigate to your project folder and run:
.\scripts\setup_azure_ad_auth.ps1 -WebAppName "your-web-app-name" -ResourceGroupName "your-resource-group"
```

Then **grant admin consent** in Azure Portal (required manual step).

**📋 Quick Reference:** See [Azure AD Quick Reference](AZURE_AD_QUICK_REFERENCE.md) for the essential steps.

**📖 Detailed Guide:** See [Azure AD Setup Guide](AZURE_AD_SETUP_GUIDE.md) for complete instructions and troubleshooting.

### Manual Setup (Alternative)

- **Add an Identity Provider:**  
  Manually configure Microsoft Entra ID authentication following the [Azure App Service Authentication docs](https://learn.microsoft.com/en-us/azure/app-service/scenario-secure-app-authentication-app-service).

### Additional Options

- **Access Control:**  
  To further restrict access, update logic in `frontend/src/pages/chat/Chat.tsx`.

- **Disabling Authentication:**  
  Set `AUTH_ENABLED=False` in environment variables to disable authentication (not recommended for production).

---

## App Configuration

See [App Settings](#app-settings) and data source configuration tables in the full documentation for all supported environment variables and their usage.

---

## Best Practices

- Reset the chat session if the user changes any settings.
- Clearly communicate the impact of each setting.
- Update app settings after rotating API keys.
- Pull changes from `main` frequently for the latest fixes and improvements.
- See the [Oryx documentation](https://github.com/microsoft/Oryx/blob/main/doc/configuration.md) for more on scalability.
- Enable debug logging via environment variables and Azure logs as described above.

---

## Contributing

This project welcomes contributions and suggestions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- By contributing, you agree to the [Contributor License Agreement (CLA)](https://cla.opensource.microsoft.com).
- Please follow the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history and update notes.

---

## Community & Support

- For questions, suggestions, or support, please open an issue or email [opencode@microsoft.com](mailto:opencode@microsoft.com).
- Join our community forum (link, if available) or Slack channel for discussions.

---

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Use of Microsoft or third-party trademarks or logos is subject to their respective policies.

---

## Disclaimer

CoPPA (College of Policing Assistant) is an advisory tool. Advice is based on curated, up-to-date data, but ultimate responsibility for decisions remains with the user.  
**Do not use this tool as a sole source for critical or time-sensitive decisions.**  
_Example scenarios where caution is required:_  
- Making legal decisions without human review  
- Relying solely on AI advice for urgent policing actions

---

## Note on Deploy to Azure Button

The "Deploy to Azure" button requires that the ARM template (deployment.json) be accessible via a public URL with CORS enabled. The template is hosted in a secure Azure Storage account with proper CORS configuration.

To make the "Deploy to Azure" button work:

1. The deployment.json file is hosted on a public storage service with CORS enabled (Azure Blob Storage configured for public access with CORS)
2. A clean, simple URL structure is used without complex query parameters
3. The URL is properly encoded in the markdown link

---

## Troubleshooting Deployment

If you encounter issues during deployment, please try the following:

### Authentication Errors
If you see authentication errors when using the one-click deployment button:
1. Make sure you're logged into Azure before clicking the button
2. Check that your Azure account has the necessary permissions to deploy resources

### Access Denied Errors
If you encounter access denied errors when accessing the template:
1. Make sure the SAS token for the blob storage hasn't expired
2. Try refreshing the page and clicking the deployment button again

### Deployment Parameter Errors
If you encounter errors related to missing or invalid parameters:
1. Make sure to fill in all required parameters in the Azure Portal
2. For sensitive values like API keys, ensure they are entered correctly
3. For region-specific resources, ensure the selected region supports all required services

For additional assistance, please contact your system administrator.

---

## Implementation Notes

This section provides technical details about the deployment process:

### Deployment Method
The one-click deployment method provides convenient deployment directly from the GitHub repository through Azure Blob Storage with proper CORS configuration.

### Automated Components Setup
- **Search Components**: The deployment automatically configures Azure Cognitive Search using a PowerShell deployment script:
  - Creates a search index with vector search capabilities
  - Sets up a data source connected to blob storage
  - Configures skillsets for document processing and embedding generation
  - Creates and runs an indexer to process documents
  - No manual setup required after deployment

### Access Requirements
- The deployment uses a SAS token for Azure Blob Storage valid until June 16, 2026

### Resource Types
The deployment template creates the following Azure resources:
- App Service Plan and Web App
- Application Insights
- Azure AI Search
- Azure OpenAI
- Cosmos DB (optional, for chat history)

---

## 🧪 Testing and Validation

### ARM Template Validation

Before deploying, always validate your ARM template to avoid costly deployment failures:

#### Quick JSON Syntax Check
```powershell
# Check JSON syntax
Get-Content "infrastructure\deployment.json" -Raw | ConvertFrom-Json
```

#### Azure PowerShell Validation
```powershell
# Ensure you're logged in
Connect-AzAccount

# Create a test resource group (or use existing)
New-AzResourceGroup -Name "policing-test-rg" -Location "East US"

# Validate the template
Test-AzResourceGroupDeployment `
  -ResourceGroupName "policing-test-rg" `
  -TemplateFile "infrastructure\deployment.json"

# What-if analysis (shows what will be deployed)
Get-AzResourceGroupDeploymentWhatIf `
  -ResourceGroupName "policing-test-rg" `
  -TemplateFile "infrastructure\deployment.json"

# Clean up test resource group
Remove-AzResourceGroup -Name "policing-test-rg" -Force
```

#### Azure CLI Validation
```bash
# Login to Azure
az login

# Create test resource group
az group create --name policing-test-rg --location eastus

# Validate template
az deployment group validate \
  --resource-group policing-test-rg \
  --template-file infrastructure/deployment.json

# What-if analysis
az deployment group what-if \
  --resource-group policing-test-rg \
  --template-file infrastructure/deployment.json

# Clean up
az group delete --name policing-test-rg --yes
```

#### Using Validation Scripts
We provide automated validation scripts in the `scripts/` folder:

```powershell
# Quick validation
cd scripts
.\quick_arm_validation.ps1

# Comprehensive validation with automatic cleanup
.\validate_arm_template.ps1 -TemplateFile "..\infrastructure\deployment.json" -CreateTestResourceGroup -CleanupAfterValidation

# Policing-specific template test
.\test_policing_template.ps1
```

#### Validation Checklist
- [ ] ✅ JSON syntax is valid
- [ ] ✅ All required parameters are defined
- [ ] ✅ Resource dependencies are correct
- [ ] ✅ Storage account names are globally unique
- [ ] ✅ API versions are current and supported
- [ ] ✅ Resource names follow Azure naming conventions
- [ ] ✅ All resources are available in target region
- [ ] ✅ What-if analysis shows expected resources

### Deployment Readiness Validation

After deployment, use our comprehensive validation scripts to ensure all components are properly configured:

#### Comprehensive Readiness Check
```powershell
# Check all components at once
.\scripts\check_deployment_readiness.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg" -StorageAccountName "yourstorageaccount" -OpenAIServiceName "your-openai-service" -SearchServiceName "your-search-service" -WaitForCompletion -FixPermissions
```

#### Individual Component Checks
```powershell
# Check OpenAI model deployments (with automatic waiting)
.\scripts\check_openai_deployments.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg" -OpenAIServiceName "your-openai-service" -WaitForCompletion

# Check storage account permissions (with automatic fixes)
.\scripts\check_storage_permissions.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg" -StorageAccountName "yourstorageaccount" -SearchServiceName "your-search-service" -Detailed -FixPermissions
```

#### Quick Connectivity Test
```powershell
# Fast connectivity check (for CI/CD pipelines)
.\scripts\check_deployment_readiness.ps1 -SubscriptionId "your-sub-id" -ResourceGroupName "your-rg" -StorageAccountName "yourstorageaccount" -OpenAIServiceName "your-openai-service" -SearchServiceName "your-search-service" -QuickCheck
```

**📖 Full Guide:** [Azure Validation Scripts Guide](AZURE_VALIDATION_SCRIPTS_GUIDE.md)

#### Post-Deployment Checklist
- [ ] ✅ All Azure resources are provisioned and running
- [ ] ✅ OpenAI models are deployed and accessible
- [ ] ✅ Storage account permissions are properly configured
- [ ] ✅ Search service is running and accessible
- [ ] ✅ Managed identities are configured
- [ ] ✅ Role assignments are in place
- [ ] ✅ Network connectivity is working
- [ ] ✅ Application startup completes successfully

### Post-Deployment Testing

After successful deployment:

1. **Test Web Application**
   - Access the deployed web app URL
   - Verify authentication works
   - Test document upload and search

2. **Validate Azure Search**
   - Check if search service is running
   - Verify index, indexer, and skillset are created
   - Test search functionality

3. **Test Azure OpenAI Integration**
   - Verify OpenAI resource is deployed
   - Test model deployments
   - Validate API connectivity

4. **Check Application Insights**
   - Verify telemetry is being collected
   - Check for any errors or warnings
