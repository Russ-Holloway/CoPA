#!/bin/bash
# CoPPA MCP Servers - Team Setup Script

set -e

echo "🚀 Setting up CoPPA MCP Servers for team development..."
echo "This will install and configure all MCP servers for the CoPPA project."
echo ""

# Check if we're in the CoPPA workspace
if [[ ! -f "azure.yaml" ]] || [[ ! -d "mcp-servers" ]]; then
    echo "❌ Please run this script from the CoPPA project root directory"
    exit 1
fi

echo "📦 Installing CoPPA Development Helper..."
cd mcp-servers/coppa-dev-helper
./setup.sh
./install-global.sh
echo "✅ CoPPA Dev Helper ready!"
echo ""

echo "🔧 Installing Azure ARM Helper..."
cd ../azure-arm-helper
./setup.sh  
./install-global.sh
echo "✅ Azure ARM Helper ready!"
echo ""

echo "📚 Microsoft Docs MCP Server..."
echo "📍 Microsoft Docs server is configured as a remote HTTP server"
echo "📍 No local installation needed - connects to https://learn.microsoft.com/api/mcp"
echo "✅ Microsoft Docs MCP ready!"
echo ""

cd ../..

echo "🔄 Loading all MCP aliases..."
source ~/.coppa_aliases 2>/dev/null || echo "CoPPA aliases will be available in new terminals"
source ~/.arm_aliases 2>/dev/null || echo "ARM aliases will be available in new terminals"
echo ""

echo "🎉 All MCP Servers are now ready for CoPPA development!"
echo ""
echo "📝 Available Commands:"
echo ""
echo "🔵 CoPPA Development Helper:"
echo "   coppa-component <name>      - Generate React components"
echo "   coppa-route <name> <path>   - Generate Flask routes"
echo "   coppa-interface <name>      - Generate TypeScript interfaces"
echo "   coppa-security              - Run security compliance check"
echo "   coppa-a11y                  - Run accessibility audit"
echo ""
echo "🟠 Azure ARM Helper:"
echo "   arm-validate <file>         - Validate ARM/Bicep templates"  
echo "   arm-web-identity           - Get web app identity reference"
echo "   arm-storage-role           - Get storage role assignment"
echo "   arm-best <file>            - Check best practices"
echo ""
echo "🟢 Microsoft Docs (via VS Code Copilot):"
echo "   Ask: 'What are the Azure CLI commands for...? **search Microsoft docs**'"
echo "   Ask: 'Show me ASP.NET Core auth patterns **fetch full doc**'"
echo ""
echo "💡 Integration Example:"
echo "   coppa-component UserAuth         # Generate component"
echo "   arm-validate infra/main.bicep    # Validate infrastructure"  
echo "   # Ask Copilot: 'What are Microsoft's recommended auth patterns for this? **search Microsoft docs**'"
echo ""
echo "📍 VS Code Integration:"
echo "   - All MCP servers are configured in .vscode/mcp.json"
echo "   - Use GitHub Copilot with Agent mode for best experience"
echo "   - Microsoft Docs server will appear as available tool in chat"
echo ""
echo "🆘 Need Help?"
echo "   - CoPPA Dev Helper: ./mcp-servers/coppa-dev-helper/README.md"
echo "   - Azure ARM Helper: ./mcp-servers/azure-arm-helper/QUICK_START.md"
echo "   - Microsoft Docs: ./mcp-servers/microsoft-docs/README.md"
echo ""
echo "✨ Happy CoPPA development!"
