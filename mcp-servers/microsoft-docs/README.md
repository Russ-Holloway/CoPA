# Microsoft Docs MCP Server Setup Guide

## 🌟 Overview

The Microsoft Learn MCP Server provides structured access to Microsoft's official documentation, including:
- **Azure services** (App Service, Cosmos DB, Functions, etc.)
- **TypeScript/React development** guidance
- **Accessibility standards** (WCAG 2.1 AA compliance)
- **Security best practices** for Microsoft technologies
- **.NET/ASP.NET Core** patterns and APIs

Perfect for CoPPA development with Azure integrations and Microsoft technology stack!

## 🔧 Installation Methods

### Method 1: One-Click VS Code Installation (Recommended)

**VS Code**: Click to install directly
[![Install in VS Code](https://img.shields.io/badge/VS_Code-Install_Microsoft_Docs_MCP-0098FF?style=flat-square&logo=visualstudiocode&logoColor=white)](https://vscode.dev/redirect/mcp/install?name=microsoft.docs.mcp&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Flearn.microsoft.com%2Fapi%2Fmcp%22%7D)

**VS Code Insiders**: Click to install directly
[![Install in VS Code Insiders](https://img.shields.io/badge/VS_Code_Insiders-Install_Microsoft_Docs_MCP-24bfa5?style=flat-square&logo=visualstudiocode&logoColor=white)](https://insiders.vscode.dev/redirect/mcp/install?name=microsoft.docs.mcp&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Flearn.microsoft.com%2Fapi%2Fmcp%22%7D)

### Method 2: Manual Configuration

1. **Open VS Code Command Palette** (`Ctrl + Shift + P`)
2. **Run**: `MCP: Open User Configuration`
3. **Add the following configuration**:

```json
{
  "microsoft.docs.mcp": {
    "type": "http",
    "url": "https://learn.microsoft.com/api/mcp"
  }
}
```

### Method 3: Workspace Configuration (Team Sharing)

Create `.vscode/mcp.json` in your workspace root:

```json
{
  "mcp": {
    "servers": {
      "microsoft.docs.mcp": {
        "type": "http",
        "url": "https://learn.microsoft.com/api/mcp"
      }
    }
  }
}
```

## 🛠️ Available Tools

| Tool Name | Description | Usage |
|-----------|-------------|--------|
| `microsoft_docs_search` | Semantic search across Microsoft documentation | Quick answers, API lookups, best practices |
| `microsoft_docs_fetch` | Fetch complete documentation pages as markdown | Deep dives, full tutorials, comprehensive guides |

## 💡 Usage Examples for CoPPA Development

### Azure Integration Queries
```
"Give me the Azure CLI commands to create an Azure Container App with a managed identity. **search Microsoft docs**"

"Show me the complete guide for deploying a .NET application to Azure App Service. **fetch full doc**"

"What are the best practices for Azure Cosmos DB integration in .NET applications? **search Microsoft docs and deep dive**"
```

### Accessibility & Security
```
"What are Microsoft's WCAG 2.1 AA implementation guidelines for React applications? **search Microsoft docs**"

"Show me the complete authentication patterns for ASP.NET Core applications. **fetch full doc**"

"How do I implement proper input validation in .NET 8 minimal APIs? **search Microsoft docs**"
```

### TypeScript & React Development
```
"Are you sure this is the right way to implement IHttpClientFactory in a .NET 8 minimal API? **search Microsoft docs and fetch full doc**"

"Get me the full step-by-step tutorial for TypeScript with ASP.NET Core. **search Microsoft docs and deep dive**"
```

## 🎯 Optimizing for CoPPA Needs

### System Prompt for Better Tool Usage

Add this to your VS Code Copilot settings or cursor rules:

```md
## Querying Microsoft Documentation

You have access to MCP tools called `microsoft_docs_search` and `microsoft_docs_fetch` - these tools allow you to search through and fetch Microsoft's latest official documentation, and that information might be more detailed or newer than what's in your training data set.

When handling questions around how to work with native Microsoft technologies, such as:
- Azure services (App Service, Cosmos DB, Functions, Container Apps)
- C#, ASP.NET Core, Entity Framework
- TypeScript/React with Microsoft tooling
- Accessibility implementation (WCAG 2.1 AA)
- Security best practices for police data
- Authentication and authorization patterns

Please use these tools for research purposes when dealing with specific or narrowly defined questions that may require up-to-date information.

Always prioritize official Microsoft documentation over general knowledge for:
1. API specifications and changes
2. Security guidelines and compliance
3. Accessibility implementation details
4. Azure service configuration
5. Authentication patterns
```

## ✅ Verification & Testing

After installation, test the setup:

1. **Open GitHub Copilot** in VS Code
2. **Switch to Agent mode** (if available)
3. **Try a test query**:
   ```
   "What are the az cli commands to create an Azure container app according to official Microsoft Learn documentation?"
   ```
4. **Look for MCP tools icon** in the chat interface
5. **Verify the agent uses the Microsoft Docs MCP Server**

## 🔧 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Connection errors | Verify network connection and server URL |
| No results returned | Try more specific technical terms in queries |
| Tool not appearing | Restart VS Code or check MCP extension installation |
| HTTP 405 error | Use through VS Code Copilot, not direct browser access |

### Getting Help

- **Ask questions**: [GitHub Discussions](https://github.com/MicrosoftDocs/mcp/discussions)
- **Report issues**: [GitHub Issues](https://github.com/MicrosoftDocs/mcp/issues)
- **Official docs**: [Microsoft Learn MCP Documentation](https://learn.microsoft.com/training/support/mcp)

## 🚀 Integration with CoPPA Development Workflow

The Microsoft Docs MCP Server complements our existing MCP servers:

```bash
# Generate CoPPA component with proper accessibility
coppa-component IncidentReport

# Validate Azure infrastructure 
arm-validate infra/main.bicep

# Get Microsoft's official guidance (NEW!)
# Ask Copilot: "What are Microsoft's recommended patterns for this component type? **search Microsoft docs**"
```

### Perfect for CoPPA Because:

1. **Azure Integration**: Official guidance for all Azure services we use
2. **Accessibility Standards**: Microsoft's WCAG 2.1 AA implementation details
3. **Security Patterns**: Official security guidelines for police data protection
4. **TypeScript/React**: Microsoft's recommended patterns and APIs
5. **Authentication**: ASP.NET Core auth patterns for secure applications
6. **Real-time Updates**: Always current with latest Microsoft guidance

## 📚 Additional Resources

- [Microsoft Learn](https://learn.microsoft.com)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)
- [VS Code MCP Official Guide](https://code.visualstudio.com/docs/copilot/mcp)
- [Azure Documentation](https://docs.microsoft.com/azure)

---

*This server provides the official source of truth for all Microsoft technologies used in CoPPA development.*
