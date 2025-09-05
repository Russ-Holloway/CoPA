#!/bin/bash
# Global Installation Script for Azure ARM Helper MCP Server

set -e

ARM_HELPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALIASES_FILE="$HOME/.arm_aliases"

echo "🚀 Setting up Azure ARM Helper for global use..."

# Create aliases file
cat > "$ALIASES_FILE" << 'EOF'
# Azure ARM Helper MCP Server Global Commands
# Generated automatically - do not edit manually

# Core ARM helper function
arm-dev() {
    local arm_helper_path
    arm_helper_path="$(find /workspaces -name "arm-dev" -path "*/azure-arm-helper/*" -type f 2>/dev/null | head -1)"
    if [[ -n "$arm_helper_path" ]]; then
        "$arm_helper_path" "$@"
    else
        echo "❌ Azure ARM Helper not found. Please ensure it's installed in your workspace."
        return 1
    fi
}

# Template validation and analysis
alias arm-validate='arm-dev validate'
alias arm-deps='arm-dev deps'
alias arm-best='arm-dev best'
alias arm-practices='arm-dev practices'

# Identity and role management
alias arm-identity='arm-dev identity'
alias arm-role='arm-dev role'

# Service management
alias arm-start='arm-dev start'
alias arm-stop='arm-dev stop'
alias arm-status='arm-dev status'
alias arm-logs='arm-dev logs'
alias arm-test='arm-dev test'

# Quick access patterns
arm-web-identity() {
    arm-dev identity "Microsoft.Web/sites" "SystemAssigned"
}

arm-func-identity() {
    arm-dev identity "Microsoft.Web/sites" "SystemAssigned"  # Function apps use same type
}

arm-storage-role() {
    local source_type="${1:-Microsoft.Web/sites}"
    arm-dev role "$source_type" "Microsoft.Storage/storageAccounts" "Storage Blob Data Contributor"
}

arm-cosmos-role() {
    local source_type="${1:-Microsoft.Web/sites}"
    arm-dev role "$source_type" "Microsoft.DocumentDB/databaseAccounts" "Cosmos DB Account Reader Role"
}

EOF

# Add to .bashrc if not already there
if ! grep -q "source.*arm_aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Azure ARM Helper aliases" >> "$HOME/.bashrc"
    echo "source $ALIASES_FILE" >> "$HOME/.bashrc"
fi

echo "✅ Added Azure ARM Helper aliases to $ALIASES_FILE"
echo ""
echo "🎉 Global setup complete!"
echo ""
echo "🔄 To start using the commands, either:"
echo "   1. Restart your terminal, or"
echo "   2. Run: source $ALIASES_FILE"
echo ""
echo "📝 Available global commands:"
echo "   arm-validate <file|content>     - Validate ARM template"
echo "   arm-deps <file|content>         - Analyze dependencies"
echo "   arm-best <file|content>         - Check best practices"
echo "   arm-identity <type> <mode>      - Fix identity references"
echo "   arm-role <source> <target> <role> - Get role assignment pattern"
echo "   arm-start/stop/status/logs      - Manage server service"
echo "   arm-test                        - Test functionality"
echo ""
echo "🚀 Quick helper functions:"
echo "   arm-web-identity               - Get web app identity reference"
echo "   arm-func-identity              - Get function app identity reference"  
echo "   arm-storage-role [source]      - Get storage role assignment"
echo "   arm-cosmos-role [source]       - Get Cosmos DB role assignment"
echo ""
echo "💡 Examples:"
echo "   arm-validate infra/main.bicep"
echo "   arm-web-identity"
echo "   arm-storage-role Microsoft.Web/sites"
echo ""
echo "📍 You can run these commands from anywhere in your workspace!"
