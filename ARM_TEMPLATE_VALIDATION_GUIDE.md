# ARM Template Validation Guide

This guide provides multiple ways to validate your ARM template before deployment to avoid costly mistakes and deployment failures.

## 🚀 Quick Start

### Option 1: Quick Validation (Recommended for daily use)
```powershell
cd scripts
.\quick_arm_validation.ps1
```

### Option 2: Comprehensive Validation (Recommended before production deployment)
```powershell
cd scripts
.\validate_arm_template.ps1 -TemplateFile "..\infrastructure\deployment.json" -CreateTestResourceGroup -CleanupAfterValidation
```

## 📋 Pre-Validation Checklist

Before running validation, ensure:

- [ ] You're logged into Azure: `Connect-AzAccount`
- [ ] You have the Azure PowerShell module: `Install-Module Az`
- [ ] You have sufficient permissions in your Azure subscription
- [ ] Your template file exists and is accessible

## 🔍 Validation Methods

### 1. JSON Syntax Validation
```powershell
# Basic JSON validation
Get-Content "infrastructure\deployment.json" -Raw | ConvertFrom-Json
```

### 2. Azure CLI Validation
```bash
# Validate template syntax
az deployment group validate \
  --resource-group "policing-validation-rg" \
  --template-file "infrastructure/deployment.json"

# What-if analysis
az deployment group what-if \
  --resource-group "policing-validation-rg" \
  --template-file "infrastructure/deployment.json"
```

### 3. PowerShell Validation
```powershell
# Test deployment without actually deploying
Test-AzResourceGroupDeployment `
  -ResourceGroupName "policing-validation-rg" `
  -TemplateFile "infrastructure\deployment.json"

# What-if analysis
Get-AzResourceGroupDeploymentWhatIf `
  -ResourceGroupName "policing-validation-rg" `
  -TemplateFile "infrastructure\deployment.json"
```

### 4. Azure Portal Validation
1. Go to Azure Portal → Resource Groups
2. Select or create a test resource group
3. Click "Create a resource" → "Template deployment"
4. Choose "Build your own template in the editor"
5. Paste your template content
6. Click "Save" to validate syntax
7. Fill parameters and click "Review + create" to validate

### 5. Online ARM Template Validation
Use these online tools for quick validation:
- [ARM Template Toolkit (arm-ttk)](https://github.com/Azure/arm-ttk)
- [ARM Template Validator](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-best-practices)

## 🛠️ Validation Script Parameters

### quick_arm_validation.ps1
```powershell
.\quick_arm_validation.ps1 -TemplateFile "path\to\template.json" -ResourceGroupName "test-rg"
```

### validate_arm_template.ps1
```powershell
.\validate_arm_template.ps1 `
  -TemplateFile "path\to\template.json" `
  -ParametersFile "path\to\parameters.json" `
  -ResourceGroupName "test-rg" `
  -Location "East US" `
  -CreateTestResourceGroup `
  -CleanupAfterValidation
```

## 🔍 What Each Validation Checks

### Syntax Validation
- ✅ JSON syntax correctness
- ✅ ARM template schema compliance
- ✅ Required fields presence
- ✅ Parameter and variable references

### Deployment Validation
- ✅ Resource provider availability
- ✅ API version compatibility
- ✅ Resource dependencies
- ✅ Parameter value constraints
- ✅ Resource naming conventions
- ✅ Subscription quotas and limits

### What-If Analysis
- 📋 Resources to be created
- 📋 Resources to be modified
- 📋 Resources to be deleted
- 📋 Resource properties changes
- 📋 Estimated cost impact

## ⚠️ Common Validation Errors and Fixes

### 1. Storage Account Name Issues
**Error**: Storage account name contains invalid characters
**Fix**: Use only lowercase letters and numbers, 3-24 characters
```json
"StorageAccountName": "[concat('st', substring(uniqueString(resourceGroup().id), 0, 11))]"
```

### 2. Resource Name Conflicts
**Error**: Resource name already exists
**Fix**: Use `uniqueString()` function
```json
"AzureOpenAIResource": "[concat('policing-ai-', uniqueString(resourceGroup().id))]"
```

### 3. API Version Warnings
**Error**: API version is deprecated
**Fix**: Update to latest stable API version
```json
"apiVersion": "2023-05-01"  // Use current version
```

### 4. Dependency Errors
**Error**: Resource depends on non-existent resource
**Fix**: Check `dependsOn` properties and resource names
```json
"dependsOn": [
  "[resourceId('Microsoft.Storage/storageAccounts', variables('StorageAccountName'))]"
]
```

### 5. Parameter Validation Errors
**Error**: Parameter value outside allowed range
**Fix**: Check parameter constraints in template
```json
"parameters": {
  "HostingPlanSku": {
    "type": "string",
    "allowedValues": ["B1", "B2", "B3", "S1", "S2", "S3"],
    "defaultValue": "B3"
  }
}
```

## 🧪 Testing Strategy

### 1. Development Testing
- Use quick validation for every change
- Test in a dedicated development resource group
- Use minimal resource sizes to reduce costs

### 2. Staging Testing
- Run comprehensive validation
- Deploy to a staging environment
- Test all application functionality
- Validate search components setup

### 3. Production Deployment
- Final validation with production parameters
- Use What-If analysis to review changes
- Deploy during maintenance window
- Monitor deployment progress

## 💰 Cost-Effective Testing

### Use Minimal Resources for Testing
```json
{
  "HostingPlanSku": "B1",           // Smallest plan
  "AzureSearchSku": "free",         // Free tier
  "storageAccountType": "Standard_LRS"  // Cheapest storage
}
```

### Delete Test Resources Quickly
```powershell
# Auto-cleanup with validation script
.\validate_arm_template.ps1 -CleanupAfterValidation

# Manual cleanup
Remove-AzResourceGroup -Name "test-rg" -Force
```

## 🔄 CI/CD Integration

### GitHub Actions Validation
```yaml
- name: Validate ARM Template
  run: |
    az deployment group validate \
      --resource-group ${{ secrets.AZURE_RG }} \
      --template-file infrastructure/deployment.json
```

### Azure DevOps Pipeline
```yaml
- task: AzureResourceManagerTemplateDeployment@3
  inputs:
    deploymentScope: 'Resource Group'
    action: 'Create Or Update Resource Group'
    resourceGroupName: '$(resourceGroupName)'
    location: '$(location)'
    templateLocation: 'Linked artifact'
    csmFile: 'infrastructure/deployment.json'
    deploymentMode: 'Validation'
```

## 📞 Getting Help

If validation fails:

1. Check the error message details
2. Review the [Common Validation Errors](#common-validation-errors-and-fixes) section
3. Use What-If analysis to understand the deployment impact
4. Test with minimal parameters first
5. Check Azure service availability in your region

## 🎯 Next Steps

After successful validation:

1. ✅ Template validation passed
2. 🚀 Ready for deployment
3. 📋 Review What-If results
4. 💾 Backup existing resources if updating
5. 🚀 Deploy using the deployment guide
6. 🔧 Run post-deployment setup scripts
