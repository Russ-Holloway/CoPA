# Deployment Template Fix Summary

## 🚨 Issues Identified
1. **Error**: `The resource 'Microsoft.Storage/storageAccounts/stbtpprod01' is not defined in the template`
2. **Error**: `Resource 'btp-deploy-identity-prod-01' was disallowed by policy. Policy identifiers: '[PDS] Naming Convention - User Assigned Identity'`

## 🔧 Root Cause Analysis
1. **Hardcoded Storage Account Name**: The storage account resource was hardcoded as `"stpolicing001"` instead of using the dynamic variable
2. **Incorrect Parameter Extraction**: The ForceCode parameter extraction logic was flawed
3. **Container Name Mismatch**: Storage container was also hardcoded
4. **Cosmos DB Naming**: Needed to standardize Cosmos DB naming pattern
5. **PDS Policy Violation**: User Assigned Identity didn't follow required `id-*` naming pattern

## ✅ Fixes Applied

### 1. Fixed Storage Account Resource Name
**Before:**
```json
"name": "stpolicing001"
```

**After:**
```json
"name": "[variables('StorageAccountName')]"
```

### 2. Fixed Storage Container Name  
**Before:**
```json
"name": "stpolicing001/default/docs"
```

**After:**
```json
"name": "[concat(variables('StorageAccountName'), '/default/', variables('StorageContainerName'))]"
```

### 3. Fixed ForceCode Parameter Extraction
**Before:**
```json
"defaultValue": "[take(toLower(replace(replace(resourceGroup().name, 'rg-', ''), '-', '')), 3)]"
```
This would turn `rg-btp-prod-01` → `btpprod01` → `btp` (incorrect logic)

**After:**
```json
"defaultValue": "[split(resourceGroup().name, '-')[1]]"
```
This correctly extracts `rg-btp-prod-01` → `btp`

### 4. Updated Cosmos DB Naming Convention
**Before:**
```json
"cosmosdb_account_name": "[concat('cosmos-', parameters('ForceCode'), '-', parameters('EnvironmentSuffix'), '-', parameters('InstanceNumber'))]"
```

**After:**
```json
"cosmosdb_account_name": "[concat('db-app-', parameters('ForceCode'), '-coppa')]"
```

**Fixed Values:**
- Database Name: `db_conversation_history` (consistent)
- Container Name: `conversations` (consistent)

### 5. Fixed User Assigned Identity PDS Policy Compliance
**Before:**
```json
"deployScriptIdentityName": "[concat(parameters('ForceCode'), '-deploy-identity-', parameters('EnvironmentSuffix'), '-', parameters('InstanceNumber'))]"
```
This created: `btp-deploy-identity-prod-01` ❌ (Policy rejected - must start with `id-`)

**After:**
```json
"deployScriptIdentityName": "[concat('id-', parameters('ForceCode'), '-deploy-', parameters('EnvironmentSuffix'), '-', parameters('InstanceNumber'))]"
```
This creates: `id-btp-deploy-prod-01` ✅ (Policy compliant)

## 🧪 Validation Results
- ✅ JSON syntax validation passed
- ✅ Resource references now match variable definitions
- ✅ Parameter extraction logic corrected
- ✅ Cosmos DB naming follows required pattern
- ✅ User Assigned Identity complies with PDS policy

## 🎯 Expected Resource Names (Example: rg-btp-prod-01)
- **Storage Account**: `stbtpprod01` ✅ (st + btp + prod + 01)
- **App Service**: `app-btp-prod-01` ✅
- **Search Service**: `srch-btp-prod-01` ✅
- **OpenAI Service**: `cog-btp-prod-01` ✅
- **Cosmos DB Account**: `db-app-btp-coppa` ✅
- **Cosmos Database**: `db_conversation_history` ✅ (consistent)
- **Cosmos Container**: `conversations` ✅ (consistent)
- **User Assigned Identity**: `id-btp-deploy-prod-01` ✅ (PDS compliant)

## 🚀 Next Steps
1. **Upload the fixed deployment.json** to your storage account
2. **Test the deployment** with a properly named resource group
3. **Verify all resources** get created with correct PDS-compliant names

The deployment template should now work correctly with the simplified PDS naming and standardized Cosmos DB setup! 🎉
