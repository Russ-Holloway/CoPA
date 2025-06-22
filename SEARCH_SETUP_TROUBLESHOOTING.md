# Search Components Setup Troubleshooting

## Overview
The PowerShell script `setup_search_components.ps1` is called during Azure deployment to automatically configure Azure Cognitive Search with:
1. Data source (connected to blob storage)
2. Search index with vector search capabilities
3. Skillsets for text processing and AI enrichment
4. Indexer to process documents

## Recent Fixes Applied

### 1. API Version Updated
- **Issue**: Script was using outdated API version `2020-06-30` which doesn't support vector search or Azure OpenAI skills
- **Fix**: Updated to `2023-07-01-Preview` to support modern features

### 2. Storage Account Configuration
- **Issue**: Hardcoded storage account name that may not exist
- **Fix**: Updated deployment template to use variables and generate unique storage account names

### 3. Container Name Mismatch
- **Issue**: Script expected different container name than what was created
- **Fix**: Aligned container name variables in deployment template

### 4. Enhanced Error Handling
- **Issue**: Limited error information when script failed
- **Fix**: Added detailed error logging and connectivity tests

## Common Issues and Solutions

### 1. Script Fails with "Resource Not Found"
**Symptoms**: Deployment script times out or fails with 404 errors

**Causes**:
- Azure Search service not fully provisioned before script runs
- OpenAI deployments not ready
- Storage account/container not created

**Solutions**:
- Check ARM template dependencies ensure proper ordering
- Verify all resource names match between template and script parameters

### 2. Vector Search Configuration Errors
**Symptoms**: Index creation fails with vector search errors

**Causes**:
- Using outdated API version
- Incorrect vector configuration syntax
- Missing dimensions specification

**Solutions**:
- Ensure API version is `2023-07-01-Preview` or later
- Verify vector field configuration matches schema

### 3. Azure OpenAI Skillset Failures
**Symptoms**: Skillset creation fails or indexer fails to process documents

**Causes**:
- Embedding deployment name mismatch
- OpenAI endpoint/key incorrect
- Model deployment not ready

**Solutions**:
- Verify embedding deployment name matches parameter
- Check OpenAI resource is in correct region
- Wait for model deployments to complete before running script

### 4. Authentication/Permission Issues
**Symptoms**: 403 Forbidden errors during script execution

**Causes**:
- Managed identity not properly configured
- Missing role assignments
- Incorrect API keys

**Solutions**:
- Verify managed identity has required permissions
- Check search service admin key is correctly passed
- Ensure storage account has proper role assignments

## Debugging Steps

### 1. Check Deployment Logs
```powershell
# In Azure Portal > Resource Group > Deployments
# Look for "setupSearchComponents" deployment
# Check Activity Log for detailed error messages
```

### 2. Manual Verification
```powershell
# Test search service connectivity
$searchUri = "https://YOUR-SEARCH-SERVICE.search.windows.net/indexes?api-version=2023-07-01-Preview"
$headers = @{ "api-key" = "YOUR-ADMIN-KEY" }
Invoke-RestMethod -Uri $searchUri -Headers $headers

# Test OpenAI service
$openaiUri = "https://YOUR-OPENAI-RESOURCE.openai.azure.com/openai/deployments?api-version=2023-05-15"
$openaiHeaders = @{ "api-key" = "YOUR-OPENAI-KEY" }
Invoke-RestMethod -Uri $openaiUri -Headers $openaiHeaders
```

### 3. Check Component Status
After deployment, verify in Azure Portal:
- Search service has index created
- Skillsets are present
- Indexer exists and is running
- Storage container has documents

## Fallback: Python Setup
If PowerShell script continues to fail, the Python application has a fallback setup that runs on first app startup:
- Located in `backend/search_setup.py`
- Automatically triggered when app starts
- Provides same functionality with better error handling

## Monitoring and Maintenance
- Indexer runs every 12 hours by default
- Monitor indexer status in Azure Portal
- Check search service usage and scaling needs
- Update skillsets if OpenAI models change
