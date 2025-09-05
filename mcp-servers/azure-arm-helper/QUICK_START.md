# Azure ARM Helper - Quick Start Guide

## 🚀 Getting Started (5 minutes)

### 1. Initial Setup
```bash
cd mcp-servers/azure-arm-helper
./setup.sh                  # Build and test the server
./install-global.sh         # Install global commands
source ~/.arm_aliases       # Load commands in current session
```

### 2. Test Everything Works
```bash
arm-test                    # Quick functionality test
arm-web-identity           # Get web app identity reference pattern
```

## 🛠️ Essential Commands

### Template Validation
```bash
# Validate a Bicep/ARM template file
arm-validate infra/main.bicep
arm-validate infra/webapp.json

# Check best practices
arm-best infra/main.bicep

# Analyze dependencies
arm-deps infra/main.bicep
```

### Identity Reference Fixes
```bash
# Fix common identity reference issues
arm-web-identity                           # Web app SystemAssigned identity
arm-func-identity                          # Function app SystemAssigned identity
arm-identity Microsoft.Web/sites UserAssigned    # Custom identity type
```

### Role Assignment Patterns
```bash
# Get correct role assignment patterns
arm-storage-role                           # Web app → Storage account
arm-cosmos-role                            # Web app → Cosmos DB
arm-role Microsoft.Web/sites Microsoft.KeyVault/vaults "Key Vault Secrets User"
```

### Service Management
```bash
arm-start                  # Start server in background
arm-status                 # Check if running
arm-logs                   # View live logs
arm-stop                   # Stop server
```

## 🎯 Real-World Examples

### Fix Identity Reference Error
**Problem**: Getting `"The language expression property 'identity' doesn't exist"`

**Solution**:
```bash
arm-web-identity
```

**Result**: Shows correct reference pattern with `'full'` parameter:
```json
"principalId": "[reference(resourceId('Microsoft.Web/sites', variables('webAppName')), '2022-09-01', 'full').identity.principalId]"
```

### Get Role Assignment Template
**Problem**: Need to give web app access to storage account

**Solution**:
```bash
arm-storage-role
```

**Result**: Complete role assignment template with correct GUIDs and dependencies.

### Validate Before Deployment
**Problem**: Want to catch issues before `azd up` fails

**Solution**:
```bash
arm-validate infra/main.bicep
arm-best infra/main.bicep
```

**Result**: Detailed validation report with fixes and recommendations.

## 🔍 Command Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `arm-validate <file>` | Validate template | `arm-validate main.bicep` |
| `arm-best <file>` | Check best practices | `arm-best webapp.json` |
| `arm-deps <file>` | Analyze dependencies | `arm-deps main.bicep` |
| `arm-identity <type> <mode>` | Identity reference | `arm-identity Microsoft.Web/sites SystemAssigned` |
| `arm-role <src> <tgt> <role>` | Role assignment | `arm-role Microsoft.Web/sites Microsoft.Storage/storageAccounts "Storage Blob Data Contributor"` |
| `arm-web-identity` | Web app identity | Quick helper |
| `arm-func-identity` | Function app identity | Quick helper |
| `arm-storage-role` | Storage role pattern | Quick helper |
| `arm-cosmos-role` | Cosmos DB role pattern | Quick helper |

## 🐛 Troubleshooting

### Server Not Starting
```bash
cd mcp-servers/azure-arm-helper
npm install
npm run build
arm-test
```

### Commands Not Found
```bash
source ~/.arm_aliases        # Reload aliases
# OR restart terminal
```

### Template Validation Fails
- Ensure file path is correct
- Check template syntax (valid JSON/Bicep)
- Try with template content directly

## 💡 Pro Tips

1. **Always validate before deployment**:
   ```bash
   arm-validate infra/main.bicep && azd up
   ```

2. **Use helpers for common patterns**:
   ```bash
   arm-web-identity     # Instead of looking up reference syntax
   arm-storage-role     # Instead of finding role GUIDs
   ```

3. **Check best practices regularly**:
   ```bash
   arm-best infra/main.bicep
   ```

4. **Monitor with logs during development**:
   ```bash
   arm-start && arm-logs
   ```

## 🚀 Integration with CoPPA Development

The ARM helper works alongside the CoPPA development helper:

```bash
# Generate infrastructure for new feature
coppa-component UserManagement
arm-validate infra/main.bicep
arm-best infra/main.bicep

# Deploy with confidence
azd up
```

Both helpers share the global command pattern and work together for full-stack CoPPA development!
