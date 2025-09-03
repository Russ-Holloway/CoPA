# Azure ARM Template Helper MCP Server

A custom Model Context Protocol (MCP) server designed specifically for Azure ARM template development, validation, and troubleshooting.

## Overview

This MCP server was created to address common issues encountered during Azure ARM template development, particularly around managed identity references and role assignments. It provides intelligent validation, suggestions, and best practices recommendations.

## Features

### 🔍 Template Validation
- **validate_arm_template**: Comprehensive ARM template syntax and structure validation
- Detects missing required properties, duplicate resources, and common errors
- Validates parameters, variables, and resource configurations

### 🛡️ Identity Reference Helper  
- **fix_identity_reference**: Provides correct managed identity reference patterns
- Supports both SystemAssigned and UserAssigned managed identities
- Addresses the common "identity property doesn't exist" errors

### 📋 Role Assignment Patterns
- **suggest_role_assignment_pattern**: Suggests correct role assignment templates
- Covers common scenarios like Web App → Storage Account, Web App → Cosmos DB
- Includes proper GUID generation and dependency handling

### 🔗 Dependency Analysis
- **analyze_dependencies**: Analyzes resource dependencies in ARM templates
- Detects circular dependencies and missing dependencies
- Provides dependency graph visualization

### ✅ Best Practices Checker
- **check_best_practices**: Validates against Azure Well-Architected Framework
- Checks naming conventions, security practices, and cost optimization
- Provides scoring and actionable recommendations

## Installation & Setup

1. **Install Dependencies**:
   ```bash
   cd mcp-servers/azure-arm-helper
   npm install
   ```

2. **Build the Server**:
   ```bash
   npm run build
   ```

3. **VS Code Integration**:
   The server is pre-configured in `.vscode/mcp.json` for easy debugging in VS Code.

## Usage Examples

### Fix Identity Reference Issue
```bash
echo 'fix_identity_reference {"resourceType": "Microsoft.Web/sites", "identityType": "SystemAssigned"}' | npm start
```

### Get Role Assignment Pattern
```bash
echo 'suggest_role_assignment_pattern {"sourceResourceType": "Microsoft.Web/sites", "targetResourceType": "Microsoft.Storage/storageAccounts", "roleDefinition": "Storage Blob Data Contributor"}' | npm start
```

### Validate ARM Template
```bash
echo 'validate_arm_template {"templateContent": "..."}' | npm start
```

## Real-World Problem Solved

This MCP server was specifically created to solve identity reference issues we encountered:

**Problem**: ARM template deployment failing with:
```
"The language expression property 'identity' doesn't exist"
```

**Solution**: The server identified that we needed to add the `'full'` parameter to our `reference()` function calls:

```json
// ❌ Incorrect
"principalId": "[reference(resourceId('Microsoft.Web/sites', variables('WebsiteName'))).identity.principalId]"

// ✅ Correct  
"principalId": "[reference(resourceId('Microsoft.Web/sites', variables('WebsiteName')), '2022-09-01', 'full').identity.principalId]"
```

## Architecture

- **TypeScript**: Strongly typed for reliability
- **Modular Design**: Separate validators and helpers for different concerns
- **Pattern-Based**: Uses known-good patterns for common scenarios
- **Extensible**: Easy to add new validation rules and patterns

## API Methods

| Method | Purpose | Parameters |
|--------|---------|------------|
| `validate_arm_template` | Template validation | `templatePath` or `templateContent` |
| `fix_identity_reference` | Identity reference fix | `resourceType`, `identityType` |
| `suggest_role_assignment_pattern` | Role assignment help | `sourceResourceType`, `targetResourceType`, `roleDefinition` |
| `analyze_dependencies` | Dependency analysis | `templatePath` or `templateContent` |
| `check_best_practices` | Best practices check | `templatePath` or `templateContent` |

## Benefits

- **Faster Development**: Quickly identify and fix common ARM template issues
- **Best Practices**: Automated checking against Azure recommendations  
- **Learning Tool**: Understand correct patterns and avoid common mistakes
- **Debugging**: Detailed error analysis and suggestions
- **Consistency**: Standardized patterns across deployments

## Contributing

This MCP server was built to solve real deployment challenges. Feel free to extend it with additional validators, patterns, and best practices as you encounter new scenarios.

---

*Built as part of the CoPPA project deployment automation improvements.*
