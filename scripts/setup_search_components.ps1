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
    [string]$openAIEmbeddingDeployment
)

# Set constants
$searchApiVersion = "2020-06-30"
$searchServiceEndpoint = "https://$searchServiceName.search.windows.net"
$headers = @{
    "Content-Type" = "application/json"
    "api-key"      = $searchServiceKey
}

# Helper function to invoke REST methods
function Invoke-SearchREST {
    param(
        [string]$method,
        [string]$uri,
        [object]$body
    )
    
    $bodyJson = $null
    if ($body) {
        $bodyJson = ConvertTo-Json -InputObject $body -Depth 20
    }
    
    $params = @{
        Method      = $method
        Uri         = $uri
        Headers     = $headers
        ContentType = "application/json"
    }
    
    if ($bodyJson) {
        $params.Body = $bodyJson
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        Write-Error "Error calling $uri : $_"
        throw $_
    }
}

# 1. Create Data Source
Write-Output "Creating data source..."
$connectionString = "DefaultEndpointsProtocol=https;AccountName=$storageAccountName;AccountKey=$storageAccountKey;EndpointSuffix=core.windows.net"
$dataSource = @{
    name = $dataSourceName
    type = "azureblob"
    credentials = @{
        connectionString = $connectionString
    }
    container = @{
        name = $storageContainerName
    }
}

$dataSourceUri = "$searchServiceEndpoint/datasources/$dataSourceName`?api-version=$searchApiVersion"
Invoke-SearchREST -method "PUT" -uri $dataSourceUri -body $dataSource

# 2. Create Index
Write-Output "Creating index..."
$index = @{
    name = $indexName
    fields = @(
        @{
            name = "id"
            type = "Edm.String"
            key = $true
            searchable = $false
        },
        @{
            name = "content"
            type = "Edm.String"
            searchable = $true
            filterable = $false
            sortable = $false
            facetable = $false
        },
        @{
            name = "title"
            type = "Edm.String"
            searchable = $true
            filterable = $true
            sortable = $true
            facetable = $false
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
            name = "category"
            type = "Edm.String"
            searchable = $true
            filterable = $true
            sortable = $false
            facetable = $true
        },
        @{
            name = "contentVector"
            type = "Collection(Edm.Single)"
            searchable = $true
            filterable = $false
            sortable = $false
            facetable = $false
            dimensions = 1536
            vectorSearchConfiguration = "vectorConfig"
        }
    )
    vectorSearch = @{
        algorithmConfigurations = @(
            @{
                name = "vectorConfig"
                kind = "hnsw"
                parameters = @{
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
                    keywordsFields = @(
                        @{
                            fieldName = "category"
                        }
                    )
                }
            }
        )
    }
}

$indexUri = "$searchServiceEndpoint/indexes/$indexName`?api-version=$searchApiVersion"
Invoke-SearchREST -method "PUT" -uri $indexUri -body $index

# 3. Create Skillset 1 - Text Processing
Write-Output "Creating text processing skillset..."
$textSkillset = @{
    name = $skillset1Name
    description = "Text processing skillset for policing documents"
    skills = @(
        @{
            "@odata.type" = "#Microsoft.Skills.Text.SplitSkill"
            name = "split-text"
            description = "Split content into pages"
            context = "/document"
            textSplitMode = "pages"
            maximumPageLength = 5000
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
            "@odata.type" = "#Microsoft.Skills.Text.LanguageDetectionSkill"
            name = "detect-language"
            description = "Detect language of the document"
            context = "/document"
            inputs = @(
                @{
                    name = "text"
                    source = "/document/content"
                }
            )
            outputs = @(
                @{
                    name = "languageCode"
                    targetName = "languageCode"
                }
            )
        },
        @{
            "@odata.type" = "#Microsoft.Skills.Text.KeyPhraseExtractionSkill"
            name = "extract-key-phrases"
            description = "Extract key phrases from each page"
            context = "/document/pages/*"
            defaultLanguageCode = "en"
            inputs = @(
                @{
                    name = "text"
                    source = "/document/pages/*"
                },
                @{
                    name = "languageCode"
                    source = "/document/languageCode"
                }
            )
            outputs = @(
                @{
                    name = "keyPhrases"
                    targetName = "keyPhrases"
                }
            )
        }
    )
}

$skillset1Uri = "$searchServiceEndpoint/skillsets/$skillset1Name`?api-version=$searchApiVersion"
Invoke-SearchREST -method "PUT" -uri $skillset1Uri -body $textSkillset

# 4. Create Skillset 2 - AI Enrichment with Azure OpenAI
Write-Output "Creating AI enrichment skillset..."
$aiSkillset = @{
    name = $skillset2Name
    description = "AI enrichment skillset using Azure OpenAI"
    skills = @(        @{
            "@odata.type" = "#Microsoft.Skills.Text.AzureOpenAIEmbeddingSkill"
            name = "text-embedding"
            description = "Generate embeddings for the document content"
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
        },        @{
            "@odata.type" = "#Microsoft.Skills.Text.AzureOpenAISkill"
            name = "document-categorizer"
            description = "Categorize documents into policing categories"
            context = "/document"            resourceUri = $openAIEndpoint
            apiKey = $openAIKey
            deploymentId = "gpt-4o"
            modelVersion = "2023-09-01-preview"
            apiVersion = "2023-05-15"
            completionOptions = @{
                temperature = 0
                maxTokens = 50
            }
            inputs = @(
                @{
                    name = "messages"
                    sourceContext = "/document"
                    inputs = @(
                        @{
                            name = "item"
                            inputs = @(
                                @{
                                    name = "role"
                                    value = "system"
                                },
                                @{
                                    name = "content"
                                    value = "You are a law enforcement document classifier. Analyze the document content and assign a single category from this list: 'Investigation', 'Patrol', 'Community', 'Evidence', 'Training', 'Legal', 'Administration', 'Intelligence', 'Emergency'. Respond with ONLY the category name."
                                }
                            )
                        },
                        @{
                            name = "item"
                            inputs = @(
                                @{
                                    name = "role"
                                    value = "user"
                                },
                                @{
                                    name = "content"
                                    source = "/document/content"
                                }
                            )
                        }
                    )
                }
            )
            outputs = @(
                @{
                    name = "output"
                    targetName = "category"
                }
            )
        }
    )
}

$skillset2Uri = "$searchServiceEndpoint/skillsets/$skillset2Name`?api-version=$searchApiVersion"
Invoke-SearchREST -method "PUT" -uri $skillset2Uri -body $aiSkillset

# 5. Create Indexer
Write-Output "Creating indexer..."
$indexer = @{
    name = $indexerName
    dataSourceName = $dataSourceName
    targetIndexName = $indexName
    skillsetName = $skillset1Name  # Primary skillset
    parameters = @{
        configuration = @{
            dataToExtract = "contentAndMetadata"
            parsingMode = "default"
        }
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
        },
        @{
            sourceFieldName = "/document/category"
            targetFieldName = "category"
        }
    )
    schedule = @{
        interval = "PT12H"  # Run every 12 hours
    }
}

$indexerUri = "$searchServiceEndpoint/indexers/$indexerName`?api-version=$searchApiVersion"
Invoke-SearchREST -method "PUT" -uri $indexerUri -body $indexer

Write-Output "Search components setup completed successfully."
