# Policing Assistant

**Policing Assistant** is an advanced AI-powered Smart Assistant designed to enhance police decision-making and effectiveness. Built within a secure Microsoft Azure environment, this assistant integrates trusted data, policy, and user feedback to deliver actionable, transparent, and secure guidance.

---

## Table of Contents

- [Vision & Purpose](#vision--purpose)
- [Key Features](#key-features)
- [How It Works](#how-it-works)
- [Key Benefits](#key-benefits)
- [Screenshots](#screenshots)
- [Quick Start](#quick-start)
- [Configure the App](#configure-the-app)
- [Deploy the App](#deploy-the-app)
- [Authentication](#authentication)
- [App Configuration](#app-configuration)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [Community & Support](#community--support)
- [Trademarks](#trademarks)
- [Disclaimer](#disclaimer)

---

## Deployment Options

### Option 1: One-Click Deployment

Click the button below to deploy directly to Azure:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fstbtpukssandopenai.blob.core.windows.net%2Fpolicing-assistant-azure-deployment-template%2Fdeployment.json%3Fsp%3Dr%26st%3D2025-06-17T17%3A37%3A38Z%26se%3D2026-06-17T01%3A37%3A38Z%26spr%3Dhttps%26sv%3D2024-11-04%26sr%3Db%26sig%3DUda77qHOroJlcDc1%252BxBcZihUuY72WBqX3h7UsnU2oTo%253D)

> **Note:** The deployment button requires you to be signed into Azure. The template is hosted in a secure Azure Storage account with proper CORS configuration.

### Option 2: Manual Template Deployment

1. **Download the deployment template:**
   - From Azure DevOps: Navigate to your Azure DevOps project, locate the `deployment.json` file, and download it
   - Or use this direct link if available: [Download Template](https://stbtpukssandopenai.blob.core.windows.net/policing-assistant-azure-deployment-template/deployment.json?sp=r&st=2025-06-17T15:38:04Z&se=2026-06-16T23:38:04Z&spr=https&sv=2024-11-04&sr=b&sig=q%2FXSsbGbQRF%2BVXyVMBlUtB%2F9CLrV01cc5EhZOkHEUfM%3D)

2. **Deploy using the Azure Portal:**
   - Go to the [Azure Portal](https://portal.azure.com)
   - Click "Create a resource" → Search for "Template deployment" → "Create"
   - Select "Build your own template in the editor"
   - Click "Load file" and upload the downloaded deployment.json file
   - Click "Save" and proceed with the deployment

### Option 3: Direct Deployment via Azure CLI

For users familiar with the Azure CLI:

```powershell
# Download the template file first
Invoke-WebRequest -Uri "https://stbtpukssandopenai.blob.core.windows.net/policing-assistant-azure-deployment-template/deployment.json?sp=r&st=2025-06-17T15:38:04Z&se=2026-06-16T23:38:04Z&spr=https&sv=2024-11-04&sr=b&sig=q%2FXSsbGbQRF%2BVXyVMBlUtB%2F9CLrV01cc5EhZOkHEUfM%3D" -OutFile "deployment.json"

# Deploy using the local file
az deployment group create --resource-group <your-resource-group-name> --template-file deployment.json
```

> **Note:** The SAS token for the deployment template is valid until June 16, 2026.

---
- [Quick Start](#quick-start)
- [Configure the App](#configure-the-app)
- [Deploy the App](#deploy-the-app)
- [Authentication](#authentication)
- [App Configuration](#app-configuration)
- [Best Practices](#best-practices)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [Community & Support](#community--support)
- [Trademarks](#trademarks)
- [Disclaimer](#disclaimer)

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
   git clone https://github.com/Russ-Holloway/Policing-Assistant.git
   cd Policing-Assistant
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

## Deploy the App

- **Azure Developer CLI:**  
  See [README_azd.md](./README_azd.md) for detailed instructions.

- **One-Click Azure Deployment:**  
  [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmicrosoft%2Fsample-app-aoai-chatGPT%2Fmain%2Fazuredeploy.json)

- **Manual Deployment:**  
  - Use Azure CLI or your preferred method. See detailed instructions in the deployment section.

---

## Authentication

- **Add an Identity Provider:**  
  After deployment, add an identity provider (e.g., Microsoft Entra ID) for authentication. See [Azure App Service Authentication docs](https://learn.microsoft.com/en-us/azure/app-service/scenario-secure-app-authentication-app-service).

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

Policing Assistant is an advisory tool. Advice is based on curated, up-to-date data, but ultimate responsibility for decisions remains with the user.  
**Do not use this tool as a sole source for critical or time-sensitive decisions.**  
_Example scenarios where caution is required:_  
- Making legal decisions without human review  
- Relying solely on AI advice for urgent policing actions

---

## Note on Deploy to Azure Button

The "Deploy to Azure" button requires that the ARM template (deployment.json) be accessible via a public URL with CORS enabled. There are several common issues that can prevent this from working:

1. **Private Repository Access**: If your Azure DevOps repository is private, Azure's deployment service cannot access the file directly.

2. **CORS Policy**: The URL hosting the template must have CORS (Cross-Origin Resource Sharing) enabled to allow Azure to download it.

3. **Authentication Requirements**: If authentication is required to access the file, the deployment process will fail.

4. **URL Encoding Complexity**: Complex URLs with special characters can sometimes cause parsing issues.

To make the "Deploy to Azure" button work directly, you would need to:

1. Host the deployment.json file on a public storage service with CORS enabled (like Azure Blob Storage configured for public access with CORS)
2. Use a clean, simple URL structure without complex query parameters
3. Ensure the URL is properly encoded in the markdown link

For most private repository scenarios, the manual deployment method (Option 2) is the most reliable approach.

---

## Troubleshooting Deployment

If you encounter issues during deployment, please try the following:

### Authentication Errors
If you see authentication errors when using the one-click deployment button:
1. Make sure you're logged into Azure DevOps before clicking the button
2. If you don't have access to the Azure DevOps repository, use Option 2 (Manual Template Deployment) instead
3. Check that your Azure account has the necessary permissions to deploy resources

### Access Denied Errors
If you encounter access denied errors when accessing the template:
1. Make sure your SAS token hasn't expired (for the blob storage option)
2. Try downloading the file manually first, then upload it in the Azure Portal
3. Use the Azure CLI method (Option 3)

### Deployment Parameter Errors
If you encounter errors related to missing or invalid parameters:
1. Make sure to fill in all required parameters in the Azure Portal
2. For sensitive values like API keys, ensure they are entered correctly
3. For region-specific resources, ensure the selected region supports all required services

For additional assistance, please contact your system administrator.

---

---

## Implementation Notes

This section provides technical details about the deployment process:

### Deployment Methods
Three deployment methods are provided:
1. One-Click Deployment - Convenient deployment directly from Azure DevOps repository
2. Manual Template Deployment - Alternative method using Azure Blob Storage
3. Azure CLI Deployment - For advanced users familiar with command-line tools

### Access Requirements
- The one-click deployment requires access to the Azure DevOps repository
- The manual deployment uses a SAS token for Azure Blob Storage valid until June 16, 2026

### Resource Types
The deployment template creates the following Azure resources:
- App Service Plan and Web App
- Application Insights
- Cosmos DB (optional, for chat history)
lowing Azure resources:
- App Service Plan and Web App
- Application Insights
- Cosmos DB (optional, for chat history)
