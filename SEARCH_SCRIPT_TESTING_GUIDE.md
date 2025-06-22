# 🔍 Testing Only the Search Script

This guide shows you how to test **only** the `setup_search_components.ps1` script without deploying the entire ARM template.

## 🎯 Quick Test Options

### Option 1: Syntax Validation Only (No Azure Resources Needed)
```powershell
cd scripts
.\validate_search_script_syntax.ps1
```
**What it does:**
- ✅ Checks PowerShell syntax
- ✅ Validates parameter definitions
- ✅ Identifies Azure cmdlets used
- ❌ Doesn't test actual functionality

### Option 2: Test with Existing Azure Resources
If you have existing Search, Storage, and OpenAI resources:

```powershell
cd scripts
.\test_search_script.ps1 `
  -SearchServiceName "your-search-service" `
  -SearchServiceKey "your-search-key" `
  -StorageAccountName "yourstorage" `
  -StorageAccountKey "your-storage-key" `
  -OpenAIEndpoint "https://your-openai.openai.azure.com/" `
  -OpenAIKey "your-openai-key"
```

### Option 3: Deploy Minimal Test Environment
Deploy only the resources needed for the search script:

```powershell
# Create test resource group
New-AzResourceGroup -Name "policing-search-test" -Location "East US"

# Deploy minimal template
New-AzResourceGroupDeployment `
  -ResourceGroupName "policing-search-test" `
  -TemplateFile "infrastructure\test_search_only.json"

# Clean up after testing
Remove-AzResourceGroup -Name "policing-search-test" -Force
```

## 🛠️ What Gets Tested

The search script creates these components:
- **Data Source**: Connection to your storage account
- **Index**: Search index with proper schema
- **Skillset**: AI skills for document processing
- **Indexer**: Processes documents and populates index

## 💰 Cost-Effective Testing

### Use Free Tiers:
- **Azure Search**: Free tier (1 service per subscription)
- **Storage**: Standard_LRS (cheapest option)
- **OpenAI**: Use existing resource or minimal capacity

### Estimated Costs for Test Environment:
- Search (Free): **$0/month**
- Storage (minimal): **~$1/month**
- OpenAI (minimal capacity): **~$10/month**

## 🔍 Debugging the Script

### Common Issues:
1. **Authentication errors**: Check keys and endpoints
2. **Resource not found**: Ensure resources exist before running script
3. **Skillset creation fails**: Usually due to OpenAI model deployment issues
4. **Index creation fails**: Check field definitions and data types

### Debug Steps:
```powershell
# 1. Test Azure PowerShell connection
Get-AzContext

# 2. Test search service connectivity
Invoke-RestMethod -Uri "https://your-search.search.windows.net/indexes?api-version=2020-06-30" -Headers @{"api-key"="your-key"}

# 3. Test storage account connectivity
$ctx = New-AzStorageContext -StorageAccountName "yourstorage" -StorageAccountKey "your-key"
Get-AzStorageContainer -Context $ctx

# 4. Test OpenAI endpoint
Invoke-RestMethod -Uri "https://your-openai.openai.azure.com/openai/deployments?api-version=2023-05-01" -Headers @{"api-key"="your-key"}
```

## 📋 Expected Script Output

When successful, the script should:
1. ✅ Create data source pointing to storage container
2. ✅ Create search index with proper fields
3. ✅ Create skillset with AI processing capabilities
4. ✅ Create indexer to process documents
5. ✅ Run indexer and report status

### Success Indicators:
- No PowerShell errors
- HTTP 201/200 responses from Azure APIs
- Indexer shows "success" status
- Search index contains processed documents

## 🚫 Troubleshooting

### Script Fails at Data Source Creation:
- Check storage account name and key
- Verify container exists
- Ensure managed identity has Storage Blob Data Reader role

### Script Fails at Skillset Creation:
- Verify OpenAI resource is deployed
- Check OpenAI model deployments exist
- Verify OpenAI endpoint and key

### Script Fails at Index Creation:
- Check for field name conflicts
- Verify data type definitions
- Ensure search service has capacity

### Indexer Fails to Run:
- Check document formats in storage
- Verify skillset is working
- Check indexer execution history in Azure Portal

## 🎯 Next Steps After Successful Test

1. **If test passes**: Your script is ready for full deployment
2. **If test fails**: Fix issues before running full ARM template
3. **Performance testing**: Upload test documents and verify search results
4. **Integration testing**: Test with your application code

## 📞 Quick Commands Reference

```powershell
# Syntax check only
.\validate_search_script_syntax.ps1

# Full test with your resources
.\test_search_script.ps1 -SearchServiceName "your-search" [other params]

# Deploy test environment
New-AzResourceGroupDeployment -ResourceGroupName "test-rg" -TemplateFile "test_search_only.json"

# Check script execution logs
Get-AzLog -ResourceGroupName "test-rg" | Where-Object {$_.ResourceType -eq "Microsoft.Resources/deploymentScripts"}
```

This approach lets you test the search components in isolation, saving time and reducing costs compared to deploying the entire application infrastructure.
