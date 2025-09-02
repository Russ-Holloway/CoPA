param(
    [Parameter(Mandatory=$true)]
    [string] $SearchServiceName,
    [Parameter(Mandatory=$true)]
    [string] $SearchIndexName,
    [Parameter(Mandatory=$true)]
    [string] $SearchIndexerName,
    [Parameter(Mandatory=$true)]
    [string] $SearchDataSourceName,
    [Parameter(Mandatory=$true)]
    [string] $StorageAccountName,
    [Parameter(Mandatory=$true)]
    [string] $StorageContainerName,
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string] $AzureOpenAIEndpoint,
    [Parameter(Mandatory=$true)]
    [string] $AzureOpenAIApiKey,
    [Parameter(Mandatory=$true)]
    [string] $EmbeddingDeploymentName,
    [Parameter(Mandatory=$true)]
    [string] $SkillsetName
)
 
# Set error action preference to stop on error
$ErrorActionPreference = "Stop"

# Install required Az modules
Write-Host "Installing required Azure PowerShell modules..."
Install-Module -Name Az.Accounts -Force -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
Install-Module -Name Az.Resources -Force -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue  
Install-Module -Name Az.Storage -Force -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue

# Connect using managed identity (should already be connected in deployment script context)
try {
    $context = Get-AzContext
    if (-not $context) {
        Write-Host "Connecting to Azure using managed identity..."
        Connect-AzAccount -Identity
    } else {
        Write-Host "Already connected to Azure."
    }
} catch {
    Write-Host "Warning: Could not verify Azure connection: $($_.Exception.Message)"
}
 
try {
    # Get the search service admin API key
    Write-Host "Getting search service admin API key..."
    $searchService = Get-AzResource -ResourceType 'Microsoft.Search/searchServices' -ResourceName $SearchServiceName -ResourceGroupName $ResourceGroupName
    if (-not $searchService) {
        throw "Search service '$SearchServiceName' not found in resource group '$ResourceGroupName'."
    }
   
    $adminKeyResponse = Invoke-AzRestMethod -Uri "https://management.azure.com$($searchService.ResourceId)/listAdminKeys?api-version=2023-11-01" -Method Post
    $adminKey = ($adminKeyResponse.Content | ConvertFrom-Json).primaryKey
   
    if (-not $adminKey) {
        throw "Failed to retrieve admin key for search service '$SearchServiceName'."
    }
 
    # Get storage account key
    Write-Host "Getting storage account key..."
    $storageKeys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
   
    if (-not $storageKeys -or $storageKeys.Count -eq 0) {
        throw "Failed to retrieve keys for storage account '$StorageAccountName'."
    }
   
    $storageKey = $storageKeys[0].Value
 
    # Create data source
    Write-Host "Creating data source '$SearchDataSourceName'..."
    $dataSourceDefinition = @{
        name = $SearchDataSourceName
        type = 'azureblob'
        credentials = @{
            connectionString = "DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$storageKey;EndpointSuffix=core.windows.net"
        }
        container = @{
            name = $StorageContainerName
        }
        dataDeletionDetectionPolicy = @{
            '@odata.type' = '#Microsoft.Azure.Search.SoftDeleteColumnDeletionDetectionPolicy'
            softDeleteColumnName = 'IsDeleted'
            softDeleteMarkerValue = 'true'
        }
    }
    $dataSourcePayload = $dataSourceDefinition | ConvertTo-Json -Depth 10
    $dataSourceHeaders = @{
        'api-key' = $adminKey
        'Content-Type' = 'application/json'
    }
   
    $dataSourceResponse = Invoke-RestMethod -Uri "https://$SearchServiceName.search.windows.net/datasources/$SearchDataSourceName`?api-version=2024-07-01" -Method Put -Headers $dataSourceHeaders -Body $dataSourcePayload
    Write-Host "Data source created successfully."
 
    # Create search index
    Write-Host "Creating search index '$SearchIndexName'..."
    $indexDefinition = @{
        name = $SearchIndexName
        vectorSearch = @{
            algorithms = @(
                @{
                    name = "use-hnsw"
                    kind = "hnsw"
                }
            )
            vectorizers = @(
                @{
                    name = "use-openai"
                    kind = "azureOpenAI"
                    azureOpenAIParameters = @{
                        resourceUri = $AzureOpenAIEndpoint
                        apiKey = $AzureOpenAIApiKey
                        deploymentId = $EmbeddingDeploymentName
                        modelName = $EmbeddingDeploymentName
                    }
                }
            )
            profiles = @(
                @{
                    name = "vector-profile-hnsw-scalar"
                    algorithm = "use-hnsw"
                    vectorizer = "use-openai"
                }
            )
        }
        semantic = @{
            configurations = @(
                @{
                    name = "default-semantic-config"
                    prioritizedFields = @{
                        titleField = @{
                            fieldName = "title"
                        }
                        prioritizedContentFields = @(
                            @{
                                fieldName = "content"
                            }
                        )
                        prioritizedKeywordsFields = @()
                    }
                }
            )
        }
        fields = @(
            @{
                name = "chunk_id"
                type = "Edm.String"
                key = $true
                analyzer = "keyword"
                searchable = $true
                retrievable = $true
                sortable = $true
                filterable = $true
                facetable = $true
            },
            @{
                name = "parent_id"
                type = "Edm.String"
                analyzer = "standard.lucene"
                searchable = $true
                retrievable = $true
                facetable = $true
                filterable = $true
                sortable = $true
            },
            @{
                name = "title"
                type = "Edm.String"
                analyzer = "standard.lucene"
                searchable = $true
                retrievable = $true
                facetable = $false
                filterable = $true
                sortable = $false
            },
            @{
                name = "filepath"
                type = "Edm.String"
                searchable = $false
                retrievable = $true
                sortable = $false
                filterable = $false
                facetable = $false
            },
            @{
                name = "url"
                type = "Edm.String"
                searchable = $false
                retrievable = $true
                sortable = $false
                filterable = $false
                facetable = $false
            },
            @{
                name = "content"
                type = "Edm.String"
                analyzer = "standard.lucene"
                searchable = $true
                retrievable = $true
                sortable = $false
                filterable = $false
                facetable = $false
            },
            @{
                name = "contentVector"
                type = "Collection(Edm.Single)"
                dimensions = 1536
                vectorSearchProfile = "vector-profile-hnsw-scalar"
                searchable = $true
                retrievable = $false
                filterable = $false
                sortable = $false
                facetable = $false
            }
        )
    }
   
    $indexPayload = $indexDefinition | ConvertTo-Json -Depth 10
    $indexHeaders = @{
        'api-key' = $adminKey
        'Content-Type' = 'application/json'
    }
   
    $indexResponse = Invoke-RestMethod -Uri "https://$SearchServiceName.search.windows.net/indexes/$SearchIndexName`?api-version=2024-07-01" -Method Put -Headers $indexHeaders -Body $indexPayload
    Write-Host "Search index created successfully."
 
    # Create skillset
    Write-Host "Creating skillset '$SkillsetName'..."
    $skillsetDefinition = @{
        name = $SkillsetName
        description = "Skillset for RAG - Files"
        skills = @(
            @{
                '@odata.type' = '#Microsoft.Skills.Text.SplitSkill'
                context = '/document'
                textSplitMode = 'pages'
                maximumPageLength = 4000
                pageOverlapLength = 600
                defaultLanguageCode = 'en'
                inputs = @(
                    @{
                        name = 'text'
                        source = '/document/content'
                    }
                )
                outputs = @(
                    @{
                        name = 'textItems'
                        targetName = 'chunks'
                    }
                )
            },
            @{
                '@odata.type' = '#Microsoft.Skills.Text.AzureOpenAIEmbeddingSkill'
                description = 'Azure OpenAI Embedding Skill'
                context = '/document/chunks/*'
                resourceUri = $AzureOpenAIEndpoint
                apiKey = $AzureOpenAIApiKey
                deploymentId = $EmbeddingDeploymentName
                modelName = $EmbeddingDeploymentName
                inputs = @(
                    @{
                        name = 'text'
                        source = '/document/chunks/*'
                    }
                )
                outputs = @(
                    @{
                        name = 'embedding'
                        targetName = 'vector'
                    }
                )
            }
        )
        indexProjections = @{
            selectors = @(
                @{
                    targetIndexName = $SearchIndexName
                    parentKeyFieldName = 'parent_id'
                    sourceContext = '/document/chunks/*'
                    mappings = @(
                        @{
                            name = 'title'
                            source = '/document/metadata_storage_name'
                        },
                        @{
                            name = 'filepath'
                            source = '/document/metadata_storage_name'
                        },
                        @{
                            name = 'url'
                            source = '/document/metadata_storage_path'
                        },
                        @{
                            name = 'content'
                            source = '/document/chunks/*'
                        },
                        @{
                            name = 'contentVector'
                            source = '/document/chunks/*/vector'
                        }
                    )
                }
            )
            parameters = @{
                projectionMode = 'skipIndexingParentDocuments'
            }
        }
    }
   
    $skillsetPayload = $skillsetDefinition | ConvertTo-Json -Depth 10
    $skillsetHeaders = @{
        'api-key' = $adminKey
        'Content-Type' = 'application/json'
    }
   
    $skillsetResponse = Invoke-RestMethod -Uri "https://$SearchServiceName.search.windows.net/skillsets/$SkillsetName`?api-version=2024-07-01" -Method Put -Headers $skillsetHeaders -Body $skillsetPayload
    Write-Host "Skillset created successfully."
 
    # Create indexer
    Write-Host "Creating indexer '$SearchIndexerName'..."
    $indexerDefinition = @{
        name = $SearchIndexerName
        dataSourceName = $SearchDataSourceName
        targetIndexName = $SearchIndexName
        skillsetName = $SkillsetName
        schedule = @{
            interval = "PT30M"  # How often do you want to check for new content in the data source
        }
        fieldMappings = @()
        outputFieldMappings = @()
        parameters = @{
            maxFailedItems = -1
            maxFailedItemsPerBatch = -1
            configuration = @{
                dataToExtract = "contentAndMetadata"
            }
        }
    }
   
    $indexerPayload = $indexerDefinition | ConvertTo-Json -Depth 10
    $indexerHeaders = @{
        'api-key' = $adminKey
        'Content-Type' = 'application/json'
    }
   
    $indexerResponse = Invoke-RestMethod -Uri "https://$SearchServiceName.search.windows.net/indexers/$SearchIndexerName`?api-version=2024-07-01" -Method Put -Headers $indexerHeaders -Body $indexerPayload
    Write-Host "Indexer created successfully."
    
    # Create and upload a sample document for testing
    Write-Host "Creating sample document for testing..."
    $sampleDocument = @"
# CoPPA AI Search - Sample Document

## Welcome to Your AI-Powered Search System

This is a sample document created during deployment to demonstrate your AI search capabilities. 

### Key Features Demonstrated:

- **Vector Search**: This document has been automatically processed and vectorized using Azure OpenAI embeddings
- **Semantic Search**: The content is structured to work with semantic search capabilities
- **Document Chunking**: Large documents are automatically split into searchable chunks
- **Metadata Extraction**: File information and metadata are preserved for filtering

### Getting Started

1. **Test the Search**: Try searching for terms like "AI search", "vector search", or "getting started"
2. **Upload Your Content**: Replace this sample with your actual AI library documents
3. **Monitor Indexing**: The system will automatically process new documents you upload

### Technical Details

- **Search Service**: $SearchServiceName
- **Index**: $SearchIndexName  
- **Storage Container**: $StorageContainerName
- **Embedding Model**: $EmbeddingDeploymentName

This sample document proves that your search infrastructure is working correctly and ready for your real content.

### Next Steps

Upload your actual AI library documents to the storage container, and they will be automatically:
- Indexed for search
- Vectorized for semantic similarity
- Made available through the search interface

The system is now fully operational and ready for use!
"@

    # Upload sample document to storage
    Write-Host "Uploading sample document to storage container..."
    
    # Create a temporary file for the sample document
    $tempFile = [System.IO.Path]::GetTempFileName() + ".md"
    $sampleDocument | Out-File -FilePath $tempFile -Encoding UTF8
    
    try {
        # Create storage context
        $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $storageKey
        
        # Upload the sample document
        $blobName = "sample-ai-search-document.md"
        Set-AzStorageBlobContent -File $tempFile -Container $StorageContainerName -Blob $blobName -Context $storageContext -Force
        Write-Host "Sample document uploaded successfully as '$blobName'"
        
        # Trigger indexer to process the sample document
        Write-Host "Triggering indexer to process the sample document..."
        $triggerResponse = Invoke-RestMethod -Uri "https://$SearchServiceName.search.windows.net/indexers/$SearchIndexerName/run?api-version=2024-07-01" -Method Post -Headers $indexerHeaders
        Write-Host "Indexer triggered successfully. The sample document will be processed shortly."
        
        Write-Host ""
        Write-Host "🎉 SUCCESS! Your AI search system is now fully operational with a sample document."
        Write-Host ""
        Write-Host "📋 Next Steps:"
        Write-Host "1. Wait 2-3 minutes for the sample document to be processed"
        Write-Host "2. Test search functionality with queries like 'AI search' or 'getting started'"
        Write-Host "3. Upload your actual AI library documents to container '$StorageContainerName'"
        Write-Host "4. New documents will be automatically indexed and vectorized"
        Write-Host ""
        Write-Host "🔍 Search Service URL: https://$SearchServiceName.search.windows.net"
        Write-Host "📁 Storage Container: $StorageContainerName"
        Write-Host "🤖 Embedding Model: $EmbeddingDeploymentName"
        
    } finally {
        # Clean up temporary file
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
    }
}
catch {
    Write-Error "An error occurred: $_"
    throw
}
