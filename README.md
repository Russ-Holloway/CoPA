# Policing Assistant

**Policing Assistant** is an advanced AI-powered Smart Assistant designed to enhance police decision-making and effectiveness. Built within a secure Microsoft Azure environment, this assistant integrates trusted data, policy, and user feedback to deliver actionable, transparent, and secure guidance.

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

### One-Click Azure Deployment

Click the button below to deploy directly to Azure with the correct GPT-4o model:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fstbtpukssandopenai.blob.core.windows.net%2Fpolicing-assistant-azure-deployment-template%2Fdeployment.json%3Fsp%3Dr%26st%3D2025-06-19T09%3A46%3A13Z%26se%3D2026-06-19T17%3A46%3A13Z%26spr%3Dhttps%26sv%3D2024-11-04%26sr%3Dc%26sig%3DREDACTED/createUIDefinitionUri/https%3A%2F%2Fstbtpukssandopenai.blob.core.windows.net%2Fpolicing-assistant-azure-deployment-template%2FcreateUiDefinition.json%3Fsp%3Dr%26st%3D2025-06-19T09%3A46%3A13Z%26se%3D2026-06-19T17%3A46%3A13Z%26spr%3Dhttps%26sv%3D2024-11-04%26sr%3Dc%26sig%3DREDACTED)

> **Note:** The deployment button provides a simple one-click experience. Just select your resource group (or create a new one), provide a name for your Web App, then click "Review + create" to deploy. All parameters are pre-configured for optimal performance with GPT-4o. No need to modify any parameters - the deployment uses the latest GPT-4o model with appropriate settings automatically.

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

### Access Requirements
- The deployment uses a SAS token for Azure Blob Storage valid until June 16, 2026

### Resource Types
The deployment template creates the following Azure resources:
- App Service Plan and Web App
- Application Insights
- Azure AI Search
- Azure OpenAI
- Cosmos DB (optional, for chat history)