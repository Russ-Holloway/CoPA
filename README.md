# CoPPA - College of Policing Assistant

**CoPPA (College of Policing Assistant)** is an AI-powered assistant designed to enhance police decision-making and effectiveness. Built on secure Microsoft Azure infrastructure, it integrates trusted data sources to deliver actionable, transparent guidance for law enforcement professionals.

---

## Quick Links

- [🚀 **Deploy to Azure**](#deployment) - One-click deployment for UK Police Forces
- [📋 **Project Structure**](#repository-structure) - Navigate the codebase
- [⚡ **Quick Start**](#quick-start) - Local development setup
- [🔒 **Security**](security/SECURITY.md) - Security policies and compliance
- [📖 **Documentation**](docs/) - Detailed guides and procedures

---

## Key Features

✅ **AI-Powered Guidance** - Advanced assistant for Criminal Justice, Investigations, Prevention, and Neighbourhood Policing  
✅ **Trusted Sources** - Integrates College of Policing APP, CPS Guidance, and local force policies  
✅ **Full Transparency** - Every response includes source citations and references  
✅ **WCAG 2.1 AA Compliant** - Fully accessible interface for all users  
✅ **PDS Compliant** - Automatic compliance with Police Digital Service standards  
✅ **Enterprise Security** - Built on secure Azure infrastructure with enterprise-grade protection  

---

## Deployment

### 🚔 **One-Click Deployment for UK Police Forces**

Deploy instantly with PDS-compliant naming and automatic configuration:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fstbtpcoppatestdeployment.blob.core.windows.net%2Fdeployment%2Fdeployment.json/createUIDefinitionUri/https%3A%2F%2Fstbtpcoppatestdeployment.blob.core.windows.net%2Fdeployment%2FcreateUiDefinition.json)

**Deployment Process:**
1. **Click Deploy** → Azure infrastructure provisioned with PDS naming
2. **Auto-Configuration** → Environment variables and search components configured
3. **Ready to Use** → Application immediately available for officers

**Post-Deployment Setup:**
- **Authentication:** Run `deployment/scripts/setup_azure_ad_auth.ps1`
- **Search Setup:** Run `deployment/scripts/setup-search-components.ps1`

📖 **Guides:** [PDS Deployment](docs/deployment/PDS-DEPLOYMENT-GUIDE.md) | [Azure Naming](docs/deployment/azure-naming-guidelines.md)

---

## Repository Structure

📁 **Organized codebase for easy navigation:**

```
├── 🏗️ Core Application
│   ├── frontend/         # React/TypeScript web application  
│   ├── backend/          # Python Flask backend services
│   └── app.py            # Main Flask application entry point
│
├── 🛠️ Deployment & Infrastructure  
│   ├── deployment/azure/  # Bicep & ARM templates
│   ├── deployment/docker/ # Container configuration
│   └── deployment/scripts/ # Deployment automation
│
├── 📚 Documentation
│   ├── docs/deployment/  # Deployment guides
│   ├── docs/development/ # Developer setup
│   └── docs/user/        # End-user guides
│
├── 🔒 Security & Testing
│   ├── security/tools/   # Security scanning tools
│   ├── security/*.md     # Security policies
│   └── tests/           # Test suites
│
└── ⚙️ Configuration
    ├── scripts/         # Data processing utilities
    ├── .github/         # CI/CD workflows
    └── azure.yaml       # Azure Developer CLI config
```

📋 **Detailed Guide:** [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)

---

---

## Key Features

- **Comprehensive Support:** Advice across Criminal Justice, Investigations, Prevention, and Neighbourhood Policing.
- **Transparency & Trust:** Every answer includes source citations.
- **Continuous Improvement:** Regular audits, user feedback, and daily data updates.
- **Security & Compliance:** Operates within a secure, compliant Azure environment with PDS naming compliance.
- **Accessibility Compliant:** Full WCAG 2.1 AA compliance ensuring inclusive access for all users including those with disabilities.
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

## Accessibility

**🌟 100% WCAG 2.1 AA Compliant** - CoPPA is designed to be inclusive and accessible to all users.

### Accessibility Features

- **✅ Full WCAG 2.1 AA Compliance:** Meets all Web Content Accessibility Guidelines Level AA requirements
- **✅ Screen Reader Support:** Compatible with NVDA, JAWS, VoiceOver, and TalkBack
- **✅ Keyboard Navigation:** Complete keyboard accessibility throughout the application
- **✅ High Contrast Support:** Proper color contrast ratios (4.5:1) for all text elements
- **✅ Focus Management:** Clear visual focus indicators and proper focus trapping
- **✅ Error Handling:** Accessible form validation with screen reader announcements
- **✅ Dynamic Content:** Live regions for real-time updates and status changes
- **✅ Responsive Design:** Works across all devices and screen sizes

### Compliance Standards

- **Web Content Accessibility Guidelines (WCAG) 2.1 Level AA**
- **UK Public Sector Bodies Accessibility Regulations 2018**
- **Equality Act 2010 compliance**
- **US Section 508 standards**

### Testing & Validation

The application has been comprehensively tested using:
- **Automated Testing:** axe-core accessibility engine
- **Manual Testing:** Keyboard navigation and screen reader testing
- **User Testing:** Validated with users who have disabilities
- **Ongoing Monitoring:** Continuous accessibility validation in CI/CD pipeline

📋 **[View Accessibility Implementation Report](ACCESSIBILITY_IMPLEMENTATION_COMPLETE.md)** - Complete technical details

---

## Screenshots

> _Include screenshots or GIFs here to demonstrate the interface and functionality._

---

## Quick Start

### Local Development Setup

1. **Clone Repository**
   ```bash
   git clone https://github.com/Russ-Holloway/CoPPA.git
   cd CoPPA
   ```

2. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   cd frontend && npm install && npm run build
   ```

3. **Configure Environment**
   - Copy `.env.example` to `.env`
   - Add your Azure service credentials
   - See [Configuration Guide](docs/development/automated_search_setup.md)

4. **Start Application**
   ```bash
   ./start.sh  # Linux/Mac
   start.cmd   # Windows
   ```

5. **Access Application**
   - Open [http://127.0.0.1:50505](http://127.0.0.1:50505)

---

## Authentication & Security

### Azure AD Authentication
Configure authentication using the automated setup script:

```powershell
deployment/scripts/setup_azure_ad_auth.ps1 -WebAppName "your-app" -ResourceGroupName "your-rg"
```

### Security Features
- Enterprise-grade Azure security
- PDS-compliant naming conventions
- WCAG 2.1 AA accessibility compliance
- Comprehensive security scanning tools

📖 **Security Documentation:** [security/SECURITY.md](security/SECURITY.md)

---

## Documentation

| Audience | Documentation |
|----------|---------------|
| **Developers** | [docs/development/](docs/development/) |
| **DevOps** | [docs/deployment/](docs/deployment/) |
| **End Users** | [docs/user/](docs/user/) |
| **Security** | [security/](security/) |

---

## Contributing

We welcome contributions! Please see:
- [Contributing Guidelines](CODE_OF_CONDUCT.md)
- [Security Policy](security/SECURITY.md)
- [Project Structure](PROJECT_STRUCTURE.md)

---

## Support & Legal

**Support:** For questions or issues, please open a GitHub issue  
**License:** See [LICENSE](LICENSE) for details  
**Disclaimer:** CoPPA is an advisory tool. Ultimate responsibility for decisions remains with the user.

---

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
- **Infrastructure Only**: The deployment creates all Azure resources (App Service, Search, OpenAI, Storage, etc.) with PDS-compliant naming
- **Manual Configuration Required**: After deployment, you need to manually set up:
  - Search components using the provided PowerShell scripts
  - Authentication configuration
  - Application code deployment

### Access Requirements
- The deployment uses a SAS token for Azure Blob Storage valid until August 1, 2026

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

---

## Police Force Customization

CoPPA now supports environment variable-based customization for police force branding. This allows Azure administrators to easily configure:

- **Police Force Logo**: Custom logo displayed in the header (admin-only visible)
- **Police Force Tagline**: Custom tagline for the police force (admin-only visible)

### Environment Variables

```bash
# Police Force Logo URL
UI_POLICE_FORCE_LOGO=https://your-storage.blob.core.windows.net/images/force-logo.png

# Police Force Custom Tagline
UI_POLICE_FORCE_TAGLINE=Serving and Protecting Our Community

# Find Out More Link - displays a button that opens in new tab
UI_FIND_OUT_MORE_LINK=https://your-website.com/about-coppa
```

### Key Features

- **Admin-Only Visibility**: Both logo and tagline are only visible to users with admin permissions
- **Environment Variable Based**: Easy to configure through Azure App Service settings
- **Fallback Support**: Falls back to defaults if environment variables are not set
- **Multiple Hosting Options**: Supports Azure Blob Storage, CDN, or base64 encoded images
- **Find Out More Button**: Optional button positioned under the feedback button that opens a configurable link in a new tab

For detailed configuration instructions, see [docs/police-force-customization.md](docs/police-force-customization.md)
