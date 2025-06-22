# 🛡️ ARM Template Validation Summary

This document provides a quick reference for validating your ARM template before deployment.

## 🚀 Quick Start Commands

### Windows (PowerShell)
```powershell
# Navigate to scripts folder
cd scripts

# Option 1: Simple batch validation
.\validate_template.cmd

# Option 2: Quick PowerShell validation
.\quick_arm_validation.ps1

# Option 3: Comprehensive validation
.\validate_arm_template.ps1 -TemplateFile "..\infrastructure\deployment.json" -CreateTestResourceGroup -CleanupAfterValidation
```

### Cross-Platform (Azure CLI)
```bash
# Validate template
az deployment group validate \
  --resource-group "policing-test-rg" \
  --template-file "infrastructure/deployment.json"

# What-if analysis  
az deployment group what-if \
  --resource-group "policing-test-rg" \
  --template-file "infrastructure/deployment.json"
```

## 📋 Validation Levels

### 1. **Syntax Validation** (1 minute)
Basic JSON and ARM schema validation
```powershell
Get-Content "infrastructure\deployment.json" -Raw | ConvertFrom-Json
```

### 2. **Azure Validation** (2-3 minutes)
Full Azure Resource Manager validation
```powershell
Test-AzResourceGroupDeployment -ResourceGroupName "test-rg" -TemplateFile "infrastructure\deployment.json"
```

### 3. **What-If Analysis** (3-5 minutes)
See exactly what will be deployed
```powershell
Get-AzResourceGroupDeploymentWhatIf -ResourceGroupName "test-rg" -TemplateFile "infrastructure\deployment.json"
```

## ✅ Pre-Validation Checklist

- [ ] **Azure Login**: `Connect-AzAccount`
- [ ] **PowerShell Module**: `Install-Module Az`
- [ ] **Template Exists**: `infrastructure\deployment.json`
- [ ] **Permissions**: Contributor role on subscription
- [ ] **Test Resource Group**: Create or use existing

## 🔍 What Gets Validated

| Component | Validation Type | Time |
|-----------|----------------|------|
| JSON Syntax | Static | < 1 min |
| ARM Schema | Static | < 1 min |
| Resource Names | Azure API | 1-2 min |
| Dependencies | Azure API | 1-2 min |
| API Versions | Azure API | 1-2 min |
| Quotas & Limits | Azure API | 2-3 min |
| Security & RBAC | Azure API | 2-3 min |

## 🚨 Common Issues & Quick Fixes

### Storage Account Name Error
```json
// OLD (may conflict)
"StorageAccountName": "policingassistantstorage"

// NEW (globally unique)
"StorageAccountName": "[concat('st', substring(uniqueString(resourceGroup().id), 0, 11))]"
```

### OpenAI Resource Name Conflict
```json
// OLD (may conflict)
"AzureOpenAIResource": "policing-assistant-openai"

// NEW (globally unique)
"AzureOpenAIResource": "[concat('policing-ai-', uniqueString(resourceGroup().id))]"
```

### API Version Warnings
```json
// Update to latest stable versions
"apiVersion": "2023-05-01"  // Check Azure REST API docs
```

## 📊 Validation Results

### ✅ Success Indicators
- No validation errors returned
- What-if shows expected resources
- All resource names are unique
- Dependencies are correct

### ❌ Failure Indicators
- JSON syntax errors
- Missing required parameters
- Resource name conflicts
- Invalid API versions
- Insufficient quotas

## 🎯 Next Steps After Validation

1. **Validation Passed** ✅
   - Review What-If results
   - Proceed to deployment
   - Monitor deployment progress

2. **Validation Failed** ❌
   - Fix reported errors
   - Re-run validation
   - Check resource availability
   - Verify subscription quotas

## 📞 Getting Help

### Error Types
- **Syntax Errors**: Check JSON formatting and ARM schema
- **Resource Conflicts**: Use `uniqueString()` functions
- **API Errors**: Update to latest API versions
- **Quota Errors**: Request quota increases or use smaller SKUs

### Documentation Links
- [ARM Template Reference](https://docs.microsoft.com/en-us/azure/templates/)
- [Azure Resource Naming](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [ARM Template Best Practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/best-practices)

## 💡 Pro Tips

1. **Always validate** before deploying to production
2. **Use test resource groups** for validation (auto-cleanup)
3. **Check What-If results** carefully before deployment
4. **Start with minimal SKUs** for testing
5. **Keep validation scripts** in your repository
6. **Automate validation** in CI/CD pipelines

---

**Remember**: Validation is free, but failed deployments can be costly! 💰
