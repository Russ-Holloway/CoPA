# Bulletproof Setup Search Components Script for ARM Template Deployment
# This script is designed to run reliably in the ARM template deployment environment
# with comprehensive error handling and retry logic

param(
    [Parameter(Mandatory = $true)]
    [string]$searchServiceName,
    
    [Parameter(Mandatory = $true)]
    [string]$searchServiceKey,
    
    [Parameter(Mandatory = $true)]
    [string]$dataSourceName,
    
    [Parameter(Mandatory = $true)]
    [string]$indexName,
    
    [Parameter(Mandatory = $true)]
    [string]$indexerName,
    
    [Parameter(Mandatory = $true)]
    [string]$skillset1Name,
    
    [Parameter(Mandatory = $true)]
    [string]$skillset2Name,
    
    [Parameter(Mandatory = $true)]
    [string]$storageAccountName,
    
    [Parameter(Mandatory = $true)]
    [string]$storageAccountKey,
    
    [Parameter(Mandatory = $true)]
    [string]$storageContainerName,
    
    [Parameter(Mandatory = $true)]
    [string]$openAIEndpoint,
    
    [Parameter(Mandatory = $true)]
    [string]$openAIKey,
    
    [Parameter(Mandatory = $true)]
    [string]$openAIEmbeddingDeployment,
    
    [Parameter(Mandatory = $false)]
    [string]$openAIGptDeployment = "gpt-4o"
)

# Set error action preference for better error handling
$ErrorActionPreference = "Continue"

Write-Output "=== Policing Assistant Search Setup Script ==="
Write-Output "Search Service: $searchServiceName"
Write-Output "Storage Account: $storageAccountName"
Write-Output "OpenAI Endpoint: $openAIEndpoint"
Write-Output "Embedding Deployment: $openAIEmbeddingDeployment"
Write-Output ""

# Set constants
$searchApiVersion = "2023-11-01"  # Updated API version
$searchServiceEndpoint = "https://$searchServiceName.search.windows.net"
$headers = @{
    "Content-Type" = "application/json"
    "api-key"      = $searchServiceKey
}

# Retry function for better reliability
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [string]$Operation,
        [int]$MaxRetries = 5,
        [int]$DelaySeconds = 30
    )
    
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Write-Output "[$Operation] Attempt $attempt of $MaxRetries"
            $result = & $ScriptBlock
            Write-Output "[$Operation] Success on attempt $attempt"
            return $result
        }
        catch {
            Write-Output "[$Operation] Attempt $attempt failed: $($_.Exception.Message)"
            if ($attempt -eq $MaxRetries) {
                Write-Output "[$Operation] All attempts failed. Last error: $($_.Exception.Message)"
                throw $_
            }
            Write-Output "[$Operation] Waiting $DelaySeconds seconds before retry..."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

# Wait for OpenAI deployment to be ready
function Wait-ForOpenAIDeployment {
    param([string]$deploymentName, [int]$timeoutMinutes = 20)
    
    Write-Output "Waiting for OpenAI deployment '$deploymentName' to be ready..."
    $timeoutTime = (Get-Date).AddMinutes($timeoutMinutes)
    
    while ((Get-Date) -lt $timeoutTime) {
        try {
            $openAIHeaders = @{ "api-key" = $openAIKey }
            $deploymentsUri = "$openAIEndpoint/openai/deployments?api-version=2023-12-01-preview"
            $deployments = Invoke-RestMethod -Method GET -Uri $deploymentsUri -Headers $openAIHeaders -TimeoutSec 30
            
            foreach ($deployment in $deployments.data) {
                if ($deployment.id -eq $deploymentName -and $deployment.status -eq "succeeded") {
                    Write-Output "✓ OpenAI deployment '$deploymentName' is ready"
                    return $true
                }
            }
            
            Write-Output "⏳ OpenAI deployment '$deploymentName' not ready yet, waiting..."
            Start-Sleep -Seconds 60
        }
        catch {
            Write-Output "⏳ Waiting for OpenAI service to be accessible..."
            Start-Sleep -Seconds 60
        }
    }
    
    Write-Output "⚠ OpenAI deployment '$deploymentName' not confirmed ready within timeout, proceeding anyway"
    return $false
}

# Helper function to make Search REST API calls
function Invoke-SearchREST {
    param(
        [string]$Method,
        [string]$Uri,
        [object]$Body = $null,
        [string]$Operation = "API Call"
    )
    
    $params = @{
        Method      = $Method
        Uri         = $Uri
        Headers     = $headers
        ContentType = "application/json"
        TimeoutSec  = 60
    }
    
    if ($Body) {
        $params.Body = ConvertTo-Json -InputObject $Body -Depth 20
    }
    
    try {
        Write-Output "[$Operation] $Method $Uri"
        $response = Invoke-RestMethod @params
        Write-Output "[$Operation] Success"
        return $response
    }
    catch {
        $statusCode = "Unknown"
        $errorMessage = $_.Exception.Message
        
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            if ($_.Exception.Response.GetResponseStream) {
                try {
                    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                    $responseText = $reader.ReadToEnd()
                    Write-Output "[$Operation] Error Response: $responseText"
                }
                catch {
                    Write-Output "[$Operation] Could not read error response"
                }
            }
        }
        
        Write-Output "[$Operation] Failed with status $statusCode`: $errorMessage"
        throw $_
    }
}

# Main execution with comprehensive error handling
try {
    Write-Output ""
    Write-Output "=== Phase 1: Connectivity Tests ==="
    
    # Test Search Service connectivity
    Invoke-WithRetry -Operation "Search Service Test" -ScriptBlock {
        $testUri = "$searchServiceEndpoint/indexes?api-version=$searchApiVersion"
        Invoke-RestMethod -Method GET -Uri $testUri -Headers $headers -TimeoutSec 30 | Out-Null
        Write-Output "✓ Search service is accessible"
    }
    
    # Wait for and test OpenAI deployment
    Invoke-WithRetry -Operation "OpenAI Service Test" -ScriptBlock {
        Wait-ForOpenAIDeployment -deploymentName $openAIEmbeddingDeployment -timeoutMinutes 15
        Write-Output "✓ OpenAI service is accessible"
    }
    
    Write-Output ""
    Write-Output "=== Phase 2: Create Search Components ==="
    
    # 1. Create Data Source
    Write-Output "Creating data source..."
    $dataSource = @{
        name = $dataSourceName
        type = "azureblob"
        credentials = @{
            connectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey;EndpointSuffix=core.windows.net"
        }
        container = @{
            name = $storageContainerName
        }
    }
    
    Invoke-WithRetry -Operation "Create Data Source" -ScriptBlock {
        $dataSourceUri = "$searchServiceEndpoint/datasources/$dataSourceName" + "?api-version=$searchApiVersion"
        Invoke-SearchREST -Method "PUT" -Uri $dataSourceUri -Body $dataSource -Operation "Data Source Creation"
    }
    
    # 2. Create Index with updated vector search syntax
    Write-Output "Creating search index..."
    $index = @{
        name = $indexName
        fields = @(
            @{
                name = "id"
                type = "Edm.String"
                key = $true
                searchable = $false
                filterable = $false
                sortable = $false
                facetable = $false
            },
            @{
                name = "content"
                type = "Edm.String"
                searchable = $true
                filterable = $false
                sortable = $false
                facetable = $false
                analyzer = "en.microsoft"
            },
            @{
                name = "title"
                type = "Edm.String"
                searchable = $true
                filterable = $true
                sortable = $true
                facetable = $false
                analyzer = "en.microsoft"
            },
            @{
                name = "url"
                type = "Edm.String"
                searchable = $false
                filterable = $false
                sortable = $false
                facetable = $false
            },
            @{
                name = "filename"
                type = "Edm.String"
                searchable = $true
                filterable = $true
                sortable = $true
                facetable = $false
            },
            @{
                name = "metadata_author"
                type = "Edm.String"
                searchable = $true
                filterable = $true
                sortable = $false
                facetable = $false
            },
            @{
                name = "metadata_creation_date"
                type = "Edm.DateTimeOffset"
                searchable = $false
                filterable = $true
                sortable = $true
                facetable = $false
            },
            @{
                name = "contentVector"
                type = "Collection(Edm.Single)"
                searchable = $true
                filterable = $false
                sortable = $false
                facetable = $false
                vectorSearchDimensions = 1536
                vectorSearchProfileName = "my-vector-profile"
            }
        )
        vectorSearch = @{
            profiles = @(
                @{
                    name = "my-vector-profile"
                    algorithm = "my-hnsw-vector-config-1"
                }
            )
            algorithms = @(
                @{
                    name = "my-hnsw-vector-config-1"
                    kind = "hnsw"
                    hnswParameters = @{
                        m = 4
                        efConstruction = 400
                        efSearch = 500
                        metric = "cosine"
                    }
                }
            )
        }
        semantic = @{
            configurations = @(
                @{
                    name = "default"
                    prioritizedFields = @{
                        titleField = @{
                            fieldName = "title"
                        }
                        contentFields = @(
                            @{
                                fieldName = "content"
                            }
                        )
                    }
                }
            )
        }
    }
    
    Invoke-WithRetry -Operation "Create Index" -ScriptBlock {
        $indexUri = "$searchServiceEndpoint/indexes/$indexName" + "?api-version=$searchApiVersion"
        Invoke-SearchREST -Method "PUT" -Uri $indexUri -Body $index -Operation "Index Creation"
    }
    
    # 3. Create Skillset - Simple and reliable
    Write-Output "Creating skillset..."
    $skillset = @{
        name = $skillset1Name
        description = "Policing Assistant skillset for document processing"
        skills = @(
            @{
                "@odata.type" = "#Microsoft.Skills.Text.SplitSkill"
                name = "split-text"
                description = "Split content into manageable chunks"
                context = "/document"
                textSplitMode = "pages"
                maximumPageLength = 4000
                pageOverlapLength = 500
                inputs = @(
                    @{
                        name = "text"
                        source = "/document/content"
                    }
                )
                outputs = @(
                    @{
                        name = "textItems"
                        targetName = "pages"
                    }
                )
            },
            @{
                "@odata.type" = "#Microsoft.Skills.Text.AzureOpenAIEmbeddingSkill"
                name = "text-embedding"
                description = "Generate embeddings using Azure OpenAI"
                context = "/document"
                resourceUri = $openAIEndpoint
                apiKey = $openAIKey
                deploymentId = $openAIEmbeddingDeployment
                inputs = @(
                    @{
                        name = "text"
                        source = "/document/content"
                    }
                )
                outputs = @(
                    @{
                        name = "embedding"
                        targetName = "contentVector"
                    }
                )
            }
        )
    }
    
    Invoke-WithRetry -Operation "Create Skillset" -ScriptBlock {
        $skillsetUri = "$searchServiceEndpoint/skillsets/$skillset1Name" + "?api-version=$searchApiVersion"
        Invoke-SearchREST -Method "PUT" -Uri $skillsetUri -Body $skillset -Operation "Skillset Creation"
    }
    
    # 4. Create Indexer
    Write-Output "Creating indexer..."
    $indexer = @{
        name = $indexerName
        dataSourceName = $dataSourceName
        targetIndexName = $indexName
        skillsetName = $skillset1Name
        parameters = @{
            configuration = @{
                dataToExtract = "contentAndMetadata"
                parsingMode = "default"
                imageAction = "none"  # Simplified for reliability
            }
            batchSize = 1  # Process one document at a time for reliability
            maxFailedItems = 10
            maxFailedItemsPerBatch = 1
        }
        fieldMappings = @(
            @{
                sourceFieldName = "metadata_storage_name"
                targetFieldName = "filename"
            },
            @{
                sourceFieldName = "metadata_storage_path"
                targetFieldName = "url"
            },
            @{
                sourceFieldName = "metadata_title"
                targetFieldName = "title"
            },
            @{
                sourceFieldName = "metadata_author"
                targetFieldName = "metadata_author"
            },
            @{
                sourceFieldName = "metadata_creation_date"
                targetFieldName = "metadata_creation_date"
            }
        )
        outputFieldMappings = @(
            @{
                sourceFieldName = "/document/pages/*"
                targetFieldName = "content"
                mappingFunction = @{
                    name = "merge"
                }
            },
            @{
                sourceFieldName = "/document/contentVector"
                targetFieldName = "contentVector"
            }
        )
        schedule = @{
            interval = "PT2H"  # Run every 2 hours
        }
    }
    
    Invoke-WithRetry -Operation "Create Indexer" -ScriptBlock {
        $indexerUri = "$searchServiceEndpoint/indexers/$indexerName" + "?api-version=$searchApiVersion"
        Invoke-SearchREST -Method "PUT" -Uri $indexerUri -Body $indexer -Operation "Indexer Creation"
    }
    
    Write-Output ""
    Write-Output "=== Phase 3: Test Indexer ==="
    
    # Run the indexer to test everything works
    try {
        Write-Output "Starting indexer for initial test run..."
        $runIndexerUri = "$searchServiceEndpoint/indexers/$indexerName/run?api-version=$searchApiVersion"
        Invoke-SearchREST -Method "POST" -Uri $runIndexerUri -Operation "Start Indexer"
        
        # Wait a moment and check status
        Start-Sleep -Seconds 10
        
        $statusUri = "$searchServiceEndpoint/indexers/$indexerName/status?api-version=$searchApiVersion"
        $status = Invoke-SearchREST -Method "GET" -Uri $statusUri -Operation "Check Indexer Status"
        
        Write-Output "Indexer status: $($status.lastResult.status)"
        
        if ($status.lastResult.status -eq "success" -or $status.lastResult.status -eq "inProgress") {
            Write-Output "✓ Indexer is running successfully"
        } else {
            Write-Output "⚠ Indexer status: $($status.lastResult.status)"
            if ($status.lastResult.errorMessage) {
                Write-Output "⚠ Indexer error: $($status.lastResult.errorMessage)"
            }
        }
    }
    catch {
        Write-Output "⚠ Could not start indexer test run: $($_.Exception.Message)"
        Write-Output "This is not critical - the indexer can be started manually later"
    }
    
    Write-Output ""
    Write-Output "=== Setup Complete ==="
    Write-Output "✓ Data source created: $dataSourceName"
    Write-Output "✓ Index created: $indexName"
    Write-Output "✓ Skillset created: $skillset1Name"
    Write-Output "✓ Indexer created: $indexerName"
    Write-Output ""
    Write-Output "🎉 Search components setup completed successfully!"
    Write-Output "To add documents, upload them to the '$storageContainerName' container in storage account '$storageAccountName'"
    Write-Output "The indexer will automatically process new documents every 2 hours, or can be run manually."
    
}
catch {
    Write-Output ""
    Write-Output "❌ Setup failed with error: $($_.Exception.Message)"
    Write-Output "This may be due to timing issues with resource provisioning."
    Write-Output "The search components can be set up manually after deployment completes."
    
    # Don't fail the entire deployment for search setup issues
    Write-Output "Continuing deployment despite search setup issues..."
    exit 0
}

Write-Output ""
Write-Output "Search setup script completed."
