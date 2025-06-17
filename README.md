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

### Option 1: One-Click Deployment (Azure DevOps)

Click the button below to deploy directly to Azure:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fdev.azure.com%2FBTPDigitalWorkplace%2FPolicing%2520Assistant%2520Deployment%2520Template%2F_apis%2Fgit%2Frepositories%2FPolicing%2520Assistant%2520Deployment%2520Template%2Fitems%3Fpath%3D%2Fdeployment.json%26api-version%3D6.0)

> **Note:** This deployment button requires Azure DevOps access. If it doesn't work, please use Option 2 below.

### Option 2: Manual Template Deployment

A reliable alternative method for deploying this solution:

1. Download the [deployment template](https://stbtpukssandopenai.blob.core.windows.net/policing-assistant-azure-deployment-template/deployment.json?sp=r&st=2025-06-17T15:38:04Z&se=2026-06-16T23:38:04Z&spr=https&sv=2024-11-04&sr=b&sig=q%2FXSsbGbQRF%2BVXyVMBlUtB%2F9CLrV01cc5EhZOkHEUfM%3D) file
2. Go to the [Azure Portal](https://portal.azure.com)
3. Click "Create a resource" → Search for "Template deployment" → "Create"
4. Select "Build your own template in the editor"
5. Click "Load file" and upload the downloaded deployment.json file
6. Click "Save" and proceed with the deployment

### Option 2: Direct Deployment via Azure CLI

For users familiar with the Azure CLI:

```powershell
# Download the template file first
Invoke-WebRequest -Uri "https://stbtpukssandopenai.blob.core.windows.net/policing-assistant-azure-deployment-template/deployment.json?sp=r&st=2025-06-17T15:38:04Z&se=2026-06-16T23:38:04Z&spr=https&sv=2024-11-04&sr=b&sig=q%2FXSsbGbQRF%2BVXyVMBlUtB%2F9CLrV01cc5EhZOkHEUfM%3D" -OutFile "deployment.json"

# Deploy using the local file
az deployment group create --resource-group <your-resource-group-name> --template-file deployment.json
```

> **Note:** The SAS token for the deployment template is valid until June 16, 2026.
```

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

**Feel free to adapt this template further for your project's unique needs! Let me know if you want more specific content for any section or have other requests.**

