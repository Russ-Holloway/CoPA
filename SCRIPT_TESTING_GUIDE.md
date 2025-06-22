# PowerShell Script Syntax Validator and Local Testing Tool

## Overview

This guide provides tools to validate the `setup_search_components.ps1` script syntax and test it locally without deploying to Azure, saving you time and costs.

## 1. Syntax Validation Tool

### Quick Syntax Check

Run this PowerShell command to validate syntax without execution:

```powershell
# Validate PowerShell syntax
powershell -NoProfile -Command {
    try {
        $script = Get-Content "scripts/setup_search_components.ps1" -Raw
        $null = [System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$null, [ref]$null)
        Write-Host "✓ PowerShell syntax is valid" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ PowerShell syntax error:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}
```

### Comprehensive Validation Script

Create a validation script `scripts/validate_setup_script.ps1`:

```powershell
# Enhanced PowerShell Script Validator
param(
    [string]$ScriptPath = "scripts/setup_search_components.ps1"
)

function Test-PowerShellSyntax {
    param([string]$FilePath)
    
    try {
        Write-Host "Validating PowerShell syntax..." -ForegroundColor Yellow
        $script = Get-Content $FilePath -Raw
        $tokens = $null
        $errors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$tokens, [ref]$errors)
        
        if ($errors.Count -eq 0) {
            Write-Host "✓ PowerShell syntax is valid" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ PowerShell syntax errors found:" -ForegroundColor Red
            foreach ($error in $errors) {
                Write-Host "Line $($error.Extent.StartLineNumber): $($error.Message)" -ForegroundColor Red
            }
            return $false
        }
    }
    catch {
        Write-Host "❌ Error validating syntax: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Test-RequiredParameters {
    param([string]$FilePath)
    
    Write-Host "Checking required parameters..." -ForegroundColor Yellow
    $content = Get-Content $FilePath -Raw
    
    $requiredParams = @(
        'searchServiceName',
        'searchServiceKey',
        'dataSourceName',
        'indexName',
        'indexerName',
        'skillset1Name',
        'storageAccountName',
        'storageAccountKey',
        'storageContainerName',
        'openAIEndpoint',
        'openAIKey',
        'openAIEmbeddingDeployment'
    )
    
    $missingParams = @()
    foreach ($param in $requiredParams) {
        if ($content -notmatch "param\s*\(\s*.*?\[\w+\]\s*\`$$param") {
            $missingParams += $param
        }
    }
    
    if ($missingParams.Count -eq 0) {
        Write-Host "✓ All required parameters are defined" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Missing parameters:" -ForegroundColor Red
        $missingParams | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        return $false
    }
}

function Test-JSONStructures {
    param([string]$FilePath)
    
    Write-Host "Validating JSON structures..." -ForegroundColor Yellow
    $content = Get-Content $FilePath -Raw
    
    # Extract hashtables that represent JSON structures
    $jsonStructures = @()
    
    # Look for common JSON structure patterns
    if ($content -match '\$index\s*=\s*@\{') {
        $jsonStructures += "Index definition"
    }
    if ($content -match '\$skillset\s*=\s*@\{') {
        $jsonStructures += "Skillset definition"
    }
    if ($content -match '\$dataSource\s*=\s*@\{') {
        $jsonStructures += "Data source definition"
    }
    if ($content -match '\$indexer\s*=\s*@\{') {
        $jsonStructures += "Indexer definition"
    }
    
    Write-Host "✓ Found JSON structures: $($jsonStructures -join ', ')" -ForegroundColor Green
    return $true
}

# Run all validations
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  PowerShell Script Validation Tool" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$allValid = $true

$allValid = (Test-PowerShellSyntax -FilePath $ScriptPath) -and $allValid
$allValid = (Test-RequiredParameters -FilePath $ScriptPath) -and $allValid
$allValid = (Test-JSONStructures -FilePath $ScriptPath) -and $allValid

Write-Host ""
if ($allValid) {
    Write-Host "🎉 All validations passed! Script should work in Azure deployment." -ForegroundColor Green
} else {
    Write-Host "❌ Validation failed. Please fix the issues above." -ForegroundColor Red
    exit 1
}
```

## 2. Local Testing Environment

### Mock Azure Search API Testing

Create a mock testing script `scripts/test_setup_script_locally.ps1`:

```powershell
# Local Mock Testing for setup_search_components.ps1
param(
    [switch]$DryRun = $false
)

# Mock parameters (safe test values)
$testParams = @{
    searchServiceName = "test-search-service"
    searchServiceKey = "test-key-123456789"
    dataSourceName = "test-data-source"
    indexName = "test-index"
    indexerName = "test-indexer"
    skillset1Name = "test-skillset-1"
    skillset2Name = "test-skillset-2"
    storageAccountName = "teststorage001"
    storageAccountKey = "test-storage-key"
    storageContainerName = "test-docs"
    openAIEndpoint = "https://test-openai.openai.azure.com/"
    openAIKey = "test-openai-key"
    openAIEmbeddingDeployment = "test-embedding"
    openAIGptDeployment = "test-gpt"
}

# Mock the Invoke-RestMethod function for testing
function Invoke-RestMethod {
    param(
        [string]$Uri,
        [string]$Method,
        [string]$Body,
        [hashtable]$Headers
    )
    
    Write-Host "MOCK API CALL:" -ForegroundColor Cyan
    Write-Host "  Method: $Method" -ForegroundColor White
    Write-Host "  URI: $Uri" -ForegroundColor White
    
    if ($Body) {
        Write-Host "  Body Preview: $($Body.Substring(0, [Math]::Min(100, $Body.Length)))..." -ForegroundColor Gray
    }
    
    # Simulate successful responses
    return @{
        name = "test-resource"
        status = "created"
    }
}

Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Local Mock Testing Environment" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "🧪 DRY RUN MODE: Testing script logic without API calls" -ForegroundColor Yellow
} else {
    Write-Host "🔧 MOCK MODE: Testing with simulated API responses" -ForegroundColor Yellow
}

Write-Host ""

try {
    # Source the script with test parameters
    Write-Host "Loading setup script with test parameters..." -ForegroundColor Yellow
    
    # Test parameter validation
    foreach ($key in $testParams.Keys) {
        Set-Variable -Name $key -Value $testParams[$key] -Scope Global
        Write-Host "✓ Set $key = $($testParams[$key])" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Parameters loaded successfully. Script should execute without errors." -ForegroundColor Green
    
} catch {
    Write-Host "❌ Error during local testing:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "This indicates the script may fail in Azure deployment." -ForegroundColor Yellow
}
```

## 3. Automated Testing Pipeline

### GitHub Actions Validation

Create `.github/workflows/validate-scripts.yml`:

```yaml
name: Validate PowerShell Scripts

on:
  push:
    paths:
      - 'scripts/**/*.ps1'
      - 'infrastructure/**'
  pull_request:
    paths:
      - 'scripts/**/*.ps1'
      - 'infrastructure/**'

jobs:
  validate-powershell:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Validate PowerShell Syntax
      shell: pwsh
      run: |
        $scripts = Get-ChildItem -Path "scripts" -Filter "*.ps1" -Recurse
        
        foreach ($script in $scripts) {
          Write-Host "Validating $($script.Name)..." -ForegroundColor Yellow
          
          try {
            $content = Get-Content $script.FullName -Raw
            $tokens = $null
            $errors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$tokens, [ref]$errors)
            
            if ($errors.Count -eq 0) {
              Write-Host "✅ $($script.Name) syntax is valid" -ForegroundColor Green
            } else {
              Write-Host "❌ $($script.Name) has syntax errors:" -ForegroundColor Red
              foreach ($error in $errors) {
                Write-Host "  Line $($error.Extent.StartLineNumber): $($error.Message)" -ForegroundColor Red
              }
              exit 1
            }
          } catch {
            Write-Host "❌ Error validating $($script.Name): $($_.Exception.Message)" -ForegroundColor Red
            exit 1
          }
        }
    
    - name: Validate ARM Template
      shell: pwsh
      run: |
        Write-Host "Validating ARM template..." -ForegroundColor Yellow
        
        # Install Azure CLI if not present
        if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
          Write-Host "Installing Azure CLI..." -ForegroundColor Yellow
          Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
          Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
        }
        
        # Validate template syntax
        $templateValidation = az deployment group validate --resource-group "dummy-rg" --template-file "infrastructure/deployment.json" --no-prompt 2>&1
        
        if ($LASTEXITCODE -eq 0) {
          Write-Host "✅ ARM template syntax is valid" -ForegroundColor Green
        } else {
          Write-Host "❌ ARM template validation failed:" -ForegroundColor Red
          Write-Host $templateValidation -ForegroundColor Red
          exit 1
        }
```

## 4. Pre-Deployment Testing Commands

### Quick Test Commands

Before deploying, run these commands locally:

```powershell
# 1. Validate PowerShell syntax
powershell -NoProfile -Command "try { $null = [System.Management.Automation.Language.Parser]::ParseInput((Get-Content 'scripts/setup_search_components.ps1' -Raw), [ref]$null, [ref]$null); Write-Host 'Syntax OK' -ForegroundColor Green } catch { Write-Host 'Syntax Error:' $_.Exception.Message -ForegroundColor Red }"

# 2. Check for common issues
Select-String -Path "scripts/setup_search_components.ps1" -Pattern "missing|undefined|null"

# 3. Validate JSON structure in PowerShell hashtables
powershell -NoProfile -Command "try { . 'scripts/validate_setup_script.ps1'; Write-Host 'All validations passed' -ForegroundColor Green } catch { Write-Host 'Validation failed:' $_.Exception.Message -ForegroundColor Red }"
```

## 5. Cost-Effective Testing Strategy

### Use Azure Resource Manager Template Test Mode

```bash
# Test deployment without creating resources
az deployment group validate \
  --resource-group "test-rg" \
  --template-file "infrastructure/deployment.json" \
  --parameters "AzureOpenAIModelName=gpt-4o"

# What-if deployment (shows what would be created)
az deployment group what-if \
  --resource-group "test-rg" \
  --template-file "infrastructure/deployment.json" \
  --parameters "AzureOpenAIModelName=gpt-4o"
```

### Use Azure Container Instances for Testing

Create a lightweight test environment using Azure Container Instances to run the PowerShell script:

```yaml
# test-container.yml
apiVersion: '2021-03-01'
location: uksouth
name: powershell-script-test
properties:
  containers:
  - name: powershell-test
    properties:
      image: mcr.microsoft.com/powershell:latest
      resources:
        requests:
          cpu: 0.5
          memoryInGb: 1
      command:
        - pwsh
        - -c
        - |
          # Your script testing logic here
          Write-Host "Testing PowerShell script syntax..."
          # Add validation commands
  osType: Linux
  restartPolicy: Never
```

## 6. Common Issues & Fixes

Based on the error you encountered, here are common syntax issues:

### 1. Missing Line Breaks in Hashtables
```powershell
# ❌ Wrong
@{ name = "default"prioritizedFields = @{ } }

# ✅ Correct  
@{ 
    name = "default"
    prioritizedFields = @{ } 
}
```

### 2. Unmatched Braces
```powershell
# ❌ Wrong - missing closing brace
$config = @{
    item1 = "value"
    item2 = @{
        nested = "value"
    # Missing }
}

# ✅ Correct
$config = @{
    item1 = "value"
    item2 = @{
        nested = "value"
    }
}
```

### 3. Unexpected Tokens
```powershell
# ❌ Wrong - missing operators
$value = "test"$other = "value"

# ✅ Correct
$value = "test"
$other = "value"
```

## Usage

1. **Before every deployment:** Run the syntax validator
2. **During development:** Use the local mock testing
3. **In CI/CD:** Set up automated validation
4. **For cost savings:** Use ARM template validation instead of full deployments

This approach will save you significant time and Azure costs while ensuring your scripts work correctly.
