# Azure Cognitive Search Setup Guide

This guide will help you set up the Azure Cognitive Search components needed for the CoPPA application after the main ARM template deployment completes.

## Prerequisites

- The ARM template has been deployed successfully
- You have access to the Azure Portal
- You have the necessary permissions to create resources in the resource group

## Setting Up Azure Cognitive Search Components

Follow these steps to configure Azure Cognitive Search with data sources, indexes, skillsets, and indexers:

### 1. Create a Storage Account for Document Storage

1. Go to the Azure Portal and navigate to your resource group
2. Click "Create" and search for "Storage account"
3. Create a new storage account with the following settings:
   - Name: Choose a unique name (must be globally unique)
   - Performance: Standard
   - Redundancy: Locally-redundant storage (LRS)
   - Other settings: Default
4. Once created, navigate to the storage account
5. Go to "Containers" and create a new container named "documents"
6. Set the access level to "Private"

### 2. Upload Documents

1. In the "documents" container, upload your policing-related documents
2. These can be PDF, Word, PowerPoint, text files, etc.

### 3. Create a Search Index

1. Navigate to your Azure Cognitive Search service that was created by the ARM template
2. Go to "Indexes" and click "Add index"
3. Use the following configuration:
   - Index name: policingindex
   - Configure your fields as follows:
     - id (Key, Retrievable)
     - content (Retrievable, Searchable)
     - title (Retrievable, Searchable, Sortable)
     - url (Retrievable)
     - filename (Retrievable, Searchable, Sortable)
     - metadata_author (Retrievable, Searchable, Filterable)
     - metadata_creation_date (Retrievable, Filterable, Sortable)
     - category (Retrievable, Searchable, Filterable, Facetable)
     - contentVector (Collection(Edm.Single), Searchable, Vector dimensions: 1536, Vector search config: vectorConfig)
   - Configure vector search settings:
     - Name: vectorConfig
     - Algorithm: HNSW
     - Parameters: m=4, efConstruction=400, efSearch=500, metric=cosine
   - Configure semantic search settings:
     - Configuration name: default
     - Title field: title
     - Content fields: content
     - Keyword fields: category

### 4. Create a Data Source

1. In your search service, go to "Data sources" and click "New data source"
2. Configure as follows:
   - Name: policingdata
   - Source: Azure Blob Storage
   - Connection string: Use the connection string from your storage account
   - Container: documents
   - Blob folder: Leave empty to include all documents
   - Description: Policing documents data source

### 5. Create the Text Processing Skillset

1. Go to "Skillsets" and click "New skillset"
2. Configure as follows:
   - Name: policing-text-skillset
   - Description: Text processing skillset for policing documents
   - Add the following skills:
     - **Split Skill**:
       - Source field: /document/content
       - Maximum page length: 5000
       - Output field name: pages
     - **Language Detection Skill**:
       - Source field: /document/content
       - Output field name: languageCode
     - **Key Phrase Extraction Skill**:
       - Source fields: /document/pages/*, /document/languageCode
       - Default language: en
       - Output field name: keyPhrases

### 6. Create the AI Enrichment Skillset

1. Create another skillset named "policing-enrichment-skillset"
2. Add the following skills:
   - **Azure OpenAI Embedding Skill**:
     - Resource URI: Your Azure OpenAI service endpoint
     - API Key: Your Azure OpenAI key
     - Deployment ID: Your embedding model deployment name
     - Source field: /document/content
     - Output field name: contentVector
   - **Azure OpenAI Skill**:
     - Resource URI: Your Azure OpenAI service endpoint
     - API Key: Your Azure OpenAI key
     - Deployment ID: gpt-4o
     - API Version: 2023-05-15
     - Configure messages:
       - System message: "You are a law enforcement document classifier. Analyze the document content and assign a single category from this list: 'Investigation', 'Patrol', 'Community', 'Evidence', 'Training', 'Legal', 'Administration', 'Intelligence', 'Emergency'. Respond with ONLY the category name."
       - User message: /document/content
     - Output field name: category

### 7. Create an Indexer

1. Go to "Indexers" and click "New indexer"
2. Configure as follows:
   - Name: policingindexer
   - Data source: policingdata
   - Target index: policingindex
   - Skillset: policing-text-skillset (primary skillset)
   - Schedule: Run every 12 hours
   - Field mappings:
     - metadata_storage_name → filename
     - metadata_storage_path → url
     - metadata_title → title
     - metadata_author → metadata_author
     - metadata_creation_date → metadata_creation_date
   - Output field mappings:
     - /document/pages/* → content (Use the merge mapping function)
     - /document/contentVector → contentVector
     - /document/category → category
   - Indexer parameters:
     - Configuration > Data to extract: Content and metadata
     - Configuration > Parsing mode: Default

### 8. Run the Indexer

1. Select your newly created indexer
2. Click "Run" to start the indexing process
3. Monitor the progress in the indexer status

### 9. Update App Configuration

1. Navigate to your Web App in the Azure Portal
2. Go to Configuration > Application settings
3. Update the following settings:
   - AZURE_SEARCH_INDEX: policingindex
   - AZURE_SEARCH_QUERY_TYPE: vector or vectorSemanticHybrid (depending on your preference)
   - AZURE_SEARCH_VECTOR_COLUMNS: contentVector
   - AZURE_SEARCH_USE_SEMANTIC_SEARCH: true (if using semantic search)

## Verification

1. Once the indexer has finished running, go to your search service
2. Select "Search explorer"
3. Run a test query to verify your documents are being indexed properly
4. Try the search functionality in your CoPPA application

## Troubleshooting

If you encounter issues:

1. Check the indexer status for error messages
2. Verify all connection strings and keys are correct
3. Ensure your documents can be parsed properly
4. Check that the field mappings are configured correctly

For more detailed guidance, refer to the [Azure Cognitive Search documentation](https://learn.microsoft.com/en-us/azure/search/).
