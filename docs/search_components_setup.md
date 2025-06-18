# Search Components Setup Guide

This document provides information about the search components that have been automatically set up during deployment.

## Components Created

The deployment has created the following Azure Cognitive Search components:

1. **Data Source**: Connected to Azure Blob Storage for document ingestion
   - Name: `policingdata` (or custom name if specified)
   - Container: `documents`

2. **Index**: Schema optimized for policing document search
   - Name: `policingindex` (or custom name if specified)
   - Features: Vector search, semantic search, and filtering capabilities

3. **Skillsets**:
   - Text Processing Skillset: Handles document splitting, language detection, and key phrase extraction
   - AI Enrichment Skillset: Generates embeddings and categorizes documents using Azure OpenAI

4. **Indexer**: Coordinates the ingestion and enrichment pipeline
   - Runs automatically every 12 hours
   - Maps metadata and content fields appropriately

## Adding Documents

To add documents to the search index:

1. Upload PDF, Word, or text files to the `documents` container in the Azure Storage account created during deployment.
2. The indexer will automatically process these documents on its next run (or you can manually run the indexer).

## Customizing Search Components

If you need to customize the search components:

1. Use the Azure Portal to navigate to your Azure Cognitive Search service
2. Select the appropriate component (index, indexer, or skillset)
3. Use the editor to modify the component's definition

For more advanced customization, refer to the Azure Cognitive Search documentation.

## Verifying Setup

To verify the search components are working correctly:

1. Upload a test document to the blob storage container
2. Navigate to the Azure Cognitive Search service in the Azure Portal
3. Manually run the indexer
4. Check the indexer status and verify the document was indexed successfully
5. Use the Search explorer to perform a test query

If you encounter any issues, check the indexer execution history for error details.
