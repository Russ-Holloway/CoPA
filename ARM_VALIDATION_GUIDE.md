# 🔍 ARM Template Validation Guide - Step by Step

## **EASIEST APPROACH: Azure Portal Validation (No tools needed)**

### Step 1: Go to Azure Portal
1. Open https://portal.azure.com
2. Sign in with your Azure account

### Step 2: Start Template Deployment
1. In the search bar, type "Deploy a custom template"
2. Click on "Deploy a custom template" service

### Step 3: Load Your Template
1. Click "Build your own template in the editor"
2. Copy the entire contents of your `infrastructure/deployment.json` file
3. Paste it into the editor
4. Click "Save"

### Step 4: Validate (Don't Deploy)
1. Fill in the required parameters:
   - **Resource Group**: Select an existing RG or create new
   - **Region**: Choose your preferred region (e.g., UK South)
   - **Azure Open AI Model Name**: `gpt-4o` (should be pre-filled)
   - **Azure Open AI Embedding Name**: `text-embedding-ada-002` (should be pre-filled)

2. Click "Review + create" button

3. **VALIDATION HAPPENS HERE** - Azure will check:
   ✅ JSON syntax
   ✅ ARM template structure
   ✅ Resource dependencies
   ✅ Parameter validation
   ✅ Resource name conflicts
   ✅ Regional availability

4. **LOOK FOR RESULTS:**
   - ✅ **Green checkmark**: "Validation passed" = Ready to deploy
   - ❌ **Red X**: "Validation failed" = Errors need fixing

5. **DO NOT CLICK "CREATE"** unless you actually want to deploy

---

## **COMMAND LINE APPROACHES (for when you have tools installed)**

### Install Azure CLI First
```bash
# Windows (PowerShell as Admin)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# Or use winget
winget install -e --id Microsoft.AzureCLI

# Or use Chocolatey
choco install azure-cli
```

### Quick Validation Commands
```bash
# Login first
az login

# Create a test resource group (if needed)
az group create --name "arm-validation-test" --location "uksouth"

# VALIDATE TEMPLATE (FREE - no resources created)
az deployment group validate \
  --resource-group "arm-validation-test" \
  --template-file "infrastructure/deployment.json" \
  --parameters "AzureOpenAIModelName=gpt-4o"

# WHAT-IF DEPLOYMENT (FREE - shows what would be created)
az deployment group what-if \
  --resource-group "arm-validation-test" \
  --template-file "infrastructure/deployment.json" \
  --parameters "AzureOpenAIModelName=gpt-4o"
```

---

## **VALIDATION CHECKLIST**

### ✅ What ARM Validation Checks:
- **JSON syntax**: Proper formatting, brackets, commas
- **ARM template schema**: Correct structure and properties
- **Resource types**: Valid Azure resource types and API versions
- **Dependencies**: Correct dependsOn relationships
- **Parameters**: Required parameters and valid values
- **Variables**: Correct variable references
- **Functions**: Valid ARM template functions
- **Resource naming**: Name length limits and character restrictions
- **Regional availability**: Resources available in specified regions
- **SKU compatibility**: Valid SKUs for each resource type

### ❌ What ARM Validation DOESN'T Check:
- **PowerShell script syntax** (in deployment scripts)
- **Application code issues**
- **Runtime configuration problems**
- **Quota limits** (you might hit limits during actual deployment)
- **Permissions** (deployment might fail due to insufficient permissions)

---

## **COMMON VALIDATION ERRORS & FIXES**

### 1. "InvalidTemplate" Error
**Cause**: JSON syntax or ARM template structure issue
**Fix**: Check JSON formatting, brackets, commas

### 2. "ResourceNotFound" Error
**Cause**: API version not supported or resource type doesn't exist
**Fix**: Update API versions in the template

### 3. "InvalidParameterValue" Error
**Cause**: Parameter value not allowed
**Fix**: Check parameter constraints and allowed values

### 4. "DependencyNotFound" Error
**Cause**: Resource dependency references invalid resource
**Fix**: Check dependsOn references match resource names

### 5. "LocationNotAvailableForResourceType" Error
**Cause**: Resource type not available in specified region
**Fix**: Change region or use different resource type

---

## **TESTING STRATEGY**

### Phase 1: Basic Validation ✅
1. **JSON syntax check** (online JSON validator)
2. **ARM template validation** (Azure Portal or CLI)

### Phase 2: Deployment Preview ✅
1. **What-if deployment** (shows planned changes)
2. **Validation mode** (checks everything except actually creating)

### Phase 3: Test Deployment 💰
1. **Small test resource group** (with cheaper SKUs)
2. **Quick cleanup** (delete RG immediately after testing)

### Phase 4: Production Deployment 💰💰
1. **Full deployment** (when everything validates successfully)

---

## **💡 PRO TIPS**

1. **Always validate first** - saves time and money
2. **Use test resource groups** - easy cleanup
3. **Check quotas** - especially for OpenAI and Azure Search
4. **Test in same region** - where you plan to deploy production
5. **Save parameters** - create a parameters file for reuse
6. **Version control** - commit working templates

---

## **NEXT STEPS AFTER VALIDATION**

✅ **If validation passes:**
- Deploy to test environment first
- Test the application functionality
- Deploy to production

❌ **If validation fails:**
- Fix the reported errors
- Re-validate until it passes
- Then proceed with deployment

The Azure Portal validation method is the easiest and most comprehensive - it's what I'd recommend starting with!
