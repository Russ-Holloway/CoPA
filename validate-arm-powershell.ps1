# ARM Template Validation using Azure PowerShell
# Alternative to Azure CLI for validation

# 1. LOGIN TO AZURE
Connect-AzAccount

# 2. BASIC TEMPLATE VALIDATION
Test-AzResourceGroupDeployment `
  -ResourceGroupName "your-test-resource-group" `
  -TemplateFile "infrastructure/deployment.json" `
  -AzureOpenAIModelName "gpt-4o" `
  -AzureOpenAIEmbeddingName "text-embedding-ada-002"

# 3. WHAT-IF DEPLOYMENT (Shows what would be created)
New-AzResourceGroupDeployment `
  -ResourceGroupName "your-test-resource-group" `
  -TemplateFile "infrastructure/deployment.json" `
  -AzureOpenAIModelName "gpt-4o" `
  -AzureOpenAIEmbeddingName "text-embedding-ada-002" `
  -WhatIf

# 4. DETAILED VALIDATION WITH OUTPUT
$validation = Test-AzResourceGroupDeployment `
  -ResourceGroupName "your-test-resource-group" `
  -TemplateFile "infrastructure/deployment.json" `
  -AzureOpenAIModelName "gpt-4o" `
  -AzureOpenAIEmbeddingName "text-embedding-ada-002"

if ($validation) {
    Write-Host "❌ Validation Errors Found:" -ForegroundColor Red
    $validation | ForEach-Object {
        Write-Host "  - $($_.Message)" -ForegroundColor Red
        Write-Host "    Details: $($_.Details)" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ Template validation passed!" -ForegroundColor Green
}
