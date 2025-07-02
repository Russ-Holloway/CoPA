# Automated Search Component Setup

CoPPA (College of Policing Assistant) includes multiple automated setup processes for Azure Cognitive Search components. This document explains the available automation options and what happens during deployment.

## Setup Options

There are two automated setup approaches available:

### Option 1: PowerShell Script (Recommended)
A standalone PowerShell script that can be run after deployment to set up all search components.

**Usage:**
```powershell
.\scripts\setup-search-components.ps1 -ResourceGroupName "your-resource-group-name" -SearchServiceName "your-search-service-name" -StorageAccountName "your-storage-account-name" -OpenAIServiceName "your-openai-service-name"
```

**Benefits:**
- More reliable and easier to debug
- Can be run multiple times safely
- Provides detailed progress output
- Allows customization of parameters

### Option 2: Application Startup Automation
The web application automatically configures search components during startup.

**Benefits:**
- Zero additional setup required
- Runs automatically with deployment
- Provides immediate value with sample documents

## What Both Options Do

Both automation approaches perform the same core setup tasks:

1. Configures a search index with vector search capabilities
2. Creates a data source connected to blob storage
3. Sets up two skillsets for document processing:
   - Text processing skillset for document splitting and language detection
   - AI enrichment skillset using Azure OpenAI for embeddings and categorization
4. Configures an indexer to connect everything together
5. Uploads sample policing documents to provide immediate value

## How It Works

The automation is implemented through these components:

1. **ARM Template**: Creates all the required Azure resources
2. **Storage Account**: Automatically created to store documents
3. **Python Setup Script**: Runs during web app startup to configure search components
4. **Sample Documents**: Automatically uploaded to provide immediate value

## Technical Implementation

### PowerShell Script Implementation
The `scripts/setup-search-components.ps1` script uses Azure CLI to:
1. Create storage account and container
2. Upload sample documents
3. Configure search index with vector capabilities
4. Set up data sources, skillsets, and indexers
5. Run initial indexing process

### Application Startup Implementation
The `backend/search_setup.py` script runs automatically when the web app starts up. It:

1. Creates or connects to the blob storage container
2. Uploads sample policing documents from the data directory
3. Creates the search index with vector search configuration
4. Sets up data sources, skillsets, and the indexer
5. Configures the proper search query type in application settings

## Verification

You can verify either setup worked by:

1. Navigating to your Azure Cognitive Search service in the Azure Portal
2. Checking that the index, indexer, data sources, and skillsets exist
3. Viewing the indexer execution history to confirm documents were indexed
4. Testing the search functionality in the CoPPA application

## Troubleshooting

### PowerShell Script Issues
If you encounter issues with the PowerShell script:
1. Ensure Azure CLI is installed and you're logged in (`az login`)
2. Verify you have appropriate permissions for all resources
3. Check the script output for specific error messages
4. Try running individual Azure CLI commands manually

### Application Startup Issues
If you encounter issues with the automatic setup:

1. Check the web app logs for any error messages
2. Verify that the storage account and container were created successfully
3. Check that the search service has the correct permissions
4. Ensure the Azure OpenAI models are deployed correctly

## Adding More Documents

You can add more documents to the system at any time:

1. Navigate to the storage account in the Azure Portal
2. Open the "documents" container
3. Upload additional policing-related documents
4. The indexer will process these documents on its scheduled run, or you can manually run the indexer in the Azure Portal
