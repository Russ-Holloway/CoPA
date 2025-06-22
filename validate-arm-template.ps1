# ARM Template Validation Commands
# Run these commands to validate your deployment template without creating resources

# 1. BASIC SYNTAX VALIDATION (Free - validates JSON structure and ARM template syntax)
az deployment group validate `
  --resource-group "your-test-resource-group" `
  --template-file "infrastructure/deployment.json" `
  --parameters "AzureOpenAIModelName=gpt-4o" "AzureOpenAIEmbeddingName=text-embedding-ada-002"

# 2. WHAT-IF DEPLOYMENT (Free - shows exactly what resources would be created/modified)
az deployment group what-if `
  --resource-group "your-test-resource-group" `
  --template-file "infrastructure/deployment.json" `
  --parameters "AzureOpenAIModelName=gpt-4o" "AzureOpenAIEmbeddingName=text-embedding-ada-002"

# 3. TEMPLATE VALIDATION WITH SPECIFIC LOCATION
az deployment group validate `
  --resource-group "your-test-resource-group" `
  --template-file "infrastructure/deployment.json" `
  --parameters "AzureOpenAIModelName=gpt-4o" "AzureOpenAIEmbeddingName=text-embedding-ada-002" `
  --mode Incremental

# 4. VALIDATE WITH CUSTOM PARAMETERS (if you want to test different configurations)
az deployment group validate `
  --resource-group "your-test-resource-group" `
  --template-file "infrastructure/deployment.json" `
  --parameters @custom-parameters.json

# Note: Replace "your-test-resource-group" with an actual resource group name
# The resource group must exist, but no resources will be created during validation
