# Online ARM Template Validation Options

## 1. Azure Portal Template Deployment
1. Go to Azure Portal (https://portal.azure.com)
2. Search for "Deploy a custom template"
3. Select "Build your own template in the editor"
4. Copy/paste your deployment.json content
5. Click "Save"
6. Fill in the parameters
7. **STOP at the "Review + create" step** - this validates without deploying
8. Click "Review + create" to see validation results
9. **DO NOT click "Create"** unless you want to deploy

## 2. ARM Template Toolkit (arm-ttk)
Download and run locally to validate templates:
```powershell
# Install ARM Template Toolkit
git clone https://github.com/Azure/arm-ttk.git
Import-Module .\arm-ttk\arm-ttk\arm-ttk.psd1

# Run validation
Test-AzTemplate -TemplatePath "infrastructure/deployment.json"
```

## 3. VS Code ARM Template Extension
1. Install "Azure Resource Manager (ARM) Tools" extension in VS Code
2. Open your deployment.json file
3. The extension will highlight syntax errors and warnings automatically
4. Use Ctrl+Shift+P and search "ARM: Validate" to run validation

## 4. GitHub Actions Validation (Automated)
Add this to .github/workflows/validate-arm.yml:
```yaml
name: Validate ARM Template
on:
  push:
    paths: ['infrastructure/**']
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    - name: Validate ARM Template
      run: |
        az deployment group validate \
          --resource-group test-rg \
          --template-file infrastructure/deployment.json \
          --parameters AzureOpenAIModelName=gpt-4o
```
