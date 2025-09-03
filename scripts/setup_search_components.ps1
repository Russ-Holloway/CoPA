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
    [str        function Get-StorageAuthorizationHeader {
            param(
                [string]$AccountName,
                [string]$AccountKey,
                [string]$Method,
                [string]$ResourcePath,
                [hashtable]$Headers,
                [int]$ContentLength = 0
            )
            $xmsHeaders = $Headers.Keys | Where-Object { $_ -match '^x-ms-' } | Sort-Object
            $canonicalizedHeaders = ($xmsHeaders | ForEach-Object { "$($_):$($Headers[$_])" }) -join "`n"
            $canonicalizedResource = "/$AccountName$ResourcePath"

            # Use the provided ContentLength for the signature
            $contentLengthStr = if ($ContentLength -gt 0) { "$ContentLength" } else { '' }roupName,
    [Parameter(Mandatory=$true)]
    [string] $AzureOpenAIEndpoint,
    [Parameter(Mandatory=$true)]
    [string] $AzureOpenAIApiKey,
    [Parameter(Mandatory=$true)]
    [string] $EmbeddingDeploymentName,
    [Parameter(Mandatory=$true)]
    [string] $SkillsetName,
    [Parameter(Mandatory=$true)]
    [string] $SubscriptionId
)
 
# Set error action preference to stop on error
$ErrorActionPreference = "Stop"

# Debug: Output all parameters
Write-Host "=== SCRIPT PARAMETERS ==="
Write-Host "SearchServiceName: $SearchServiceName"
Write-Host "ResourceGroupName: $ResourceGroupName"
Write-Host "StorageAccountName: $StorageAccountName"
Write-Host "SubscriptionId: $SubscriptionId"
Write-Host "=========================="

# Install required Az modules
Write-Host "Checking and installing required Azure PowerShell modules..."
try {
    # Use REST API approach to avoid module conflicts in deployment script environment
    Write-Host "Deployment script environment detected - using REST API approach to avoid assembly conflicts..."
    
    # Skip module installation in deployment script context to avoid "Assembly with same name is already loaded"
    $useRestApi = $true
    Write-Host "Will use Azure REST API for resource management to avoid PowerShell module conflicts."
    
} catch {
    Write-Host "Warning: Module setup encountered issues. Will use REST API fallback."
    Write-Host "Error: $($_.Exception.Message)"
    $useRestApi = $true
}

# Get authentication token for REST API calls
try {
    Write-Host "Setting up authentication for REST API calls..."
    
    # In deployment script context, we should already be authenticated
    # Get access token using the managed identity
    $tokenResponse = Invoke-RestMethod -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/" -Method Get -Headers @{Metadata="true"} -ErrorAction Stop
    $accessToken = $tokenResponse.access_token
    
    Write-Host "Successfully obtained access token for Azure REST API."
    $authHeaders = @{
        'Authorization' = "Bearer $accessToken"
        'Content-Type' = 'application/json'
    }
    
} catch {
    Write-Host "Error getting access token: $($_.Exception.Message)"
    throw "Could not authenticate with Azure. Please check managed identity configuration."
}
 
try {
    # Get the search service admin API key using REST API
    Write-Host "Getting search service admin API key using REST API..."
    
    Write-Host "Building REST API URL..."
    $searchServiceUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Search/searchServices/$SearchServiceName"
    Write-Host "Search Service URI: $searchServiceUri"
    
    # First verify the search service exists
    Write-Host "Verifying search service exists..."
    try {
        $searchServiceResponse = Invoke-RestMethod -Uri "$searchServiceUri`?api-version=2023-11-01" -Method Get -Headers $authHeaders -ErrorAction Stop
        Write-Host "Found search service: $($searchServiceResponse.name)"
    } catch {
        Write-Host "Error verifying search service: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.Content.ReadAsStringAsync().Result
            Write-Host "Error response: $errorResponse"
        }
        throw
    }
    
    # Get admin keys
    Write-Host "Getting admin keys..."
    try {
        $adminKeyResponse = Invoke-RestMethod -Uri "$searchServiceUri/listAdminKeys?api-version=2023-11-01" -Method Post -Headers $authHeaders -ErrorAction Stop
    } catch {
        Write-Host "Error getting admin keys: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $errorResponse = $_.Exception.Response.Content.ReadAsStringAsync().Result
            Write-Host "Error response: $errorResponse"
        }
        throw
    }
    # Invoke-RestMethod already returns a parsed object; prefer direct property access
    $adminKey = $adminKeyResponse.primaryKey
    if (-not $adminKey -and $adminKeyResponse.Content) {
        $adminKey = ($adminKeyResponse.Content | ConvertFrom-Json).primaryKey
    }
   
    if (-not $adminKey) {
        throw "Failed to retrieve admin key for search service '$SearchServiceName'."
    }
 
    # Get storage account key using REST API
    Write-Host "Getting storage account key using REST API..."
    $storageAccountUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName"
    $storageKeysResponse = Invoke-RestMethod -Uri "$storageAccountUri/listKeys?api-version=2023-01-01" -Method Post -Headers $authHeaders -ErrorAction Stop
   
    if (-not $storageKeysResponse.keys -or $storageKeysResponse.keys.Count -eq 0) {
        throw "Failed to retrieve keys for storage account '$StorageAccountName'."
    }
   
    $storageKey = $storageKeysResponse.keys[0].value
 
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
        # Upload the sample document via Storage REST API to avoid Az.* module dependencies
        $blobName = "sample-ai-search-document.md"
        Write-Host "Uploading blob '$blobName' to container '$StorageContainerName' using REST..."

        function Get-StorageAuthorizationHeader {
            param(
                [string]$AccountName,
                [string]$AccountKey,
                [string]$Method,
                [string]$ResourcePath, # e.g., "/$StorageContainerName/$blobName"
                [hashtable]$Headers
            )
            $xmsHeaders = $Headers.Keys | Where-Object { $_ -match '^x-ms-' } | Sort-Object
            $canonicalizedHeaders = ($xmsHeaders | ForEach-Object { "$($_):$($Headers[$_])" }) -join "`n"
            $canonicalizedResource = "/$AccountName$ResourcePath"

            # For blob storage REST API, we need Content-Length in the signature but not in headers
            $contentLength = if ($Headers.ContainsKey('Content-Length')) { "$($Headers['Content-Length'])" } else { '0' }
            if ($Method -eq 'PUT' -and $contentLength -eq '0') { $contentLength = '' }

        $stringToSign = @(
                $Method,
                '', # Content-Encoding
                '', # Content-Language
                $contentLengthStr,
                '', # Content-MD5
                '', # Content-Type
                '', # Date
                '', # If-Modified-Since
                '', # If-Match
                '', # If-None-Match
                '', # If-Unmodified-Since
                '', # Range
                $canonicalizedHeaders,
                $canonicalizedResource
            ) -join "`n"

            $hmacKey = [Convert]::FromBase64String($AccountKey)
            $hmac = New-Object System.Security.Cryptography.HMACSHA256
            $hmac.Key = $hmacKey
            $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign))
            $signature = [Convert]::ToBase64String($signatureBytes)
        return ("SharedKey {0}:{1}" -f $AccountName, $signature)
        }

        $fileBytes = [System.IO.File]::ReadAllBytes($tempFile)
        $contentLength = $fileBytes.Length
        $xmsDate = [DateTime]::UtcNow.ToString('R')
        $xmsVersion = '2020-10-02'
        $resourcePath = "/$StorageContainerName/$blobName"
        $blobUri = "https://$StorageAccountName.blob.core.windows.net$resourcePath"
        $putHeaders = @{
            'x-ms-blob-type' = 'BlockBlob'
            'x-ms-date' = $xmsDate
            'x-ms-version' = $xmsVersion
        }
        $authHeader = Get-StorageAuthorizationHeader -AccountName $StorageAccountName -AccountKey $storageKey -Method 'PUT' -ResourcePath $resourcePath -Headers $putHeaders -ContentLength $contentLength
        $headers = $putHeaders.Clone()
        $headers['Authorization'] = $authHeader

        try {
            Invoke-RestMethod -Uri $blobUri -Method Put -Headers $headers -Body $fileBytes -SkipHeaderValidation -ErrorAction Stop | Out-Null
            Write-Host "Sample document uploaded successfully as '$blobName'"
        } catch {
            Write-Host "Error uploading blob: $($_.Exception.Message)"
            if ($_.Exception.Response) { $err = $_.Exception.Response.Content.ReadAsStringAsync().Result; Write-Host "Error response: $err" }
            throw
        }
        
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
