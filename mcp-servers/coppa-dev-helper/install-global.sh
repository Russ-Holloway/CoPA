#!/bin/bash
# CoPPA Development Helper - Global Installation Script
# Run this once to set up the coppa-dev command globally in your CoPPA workspace

set -e

COPPA_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MCP_DIR="$COPPA_ROOT/mcp-servers/coppa-dev-helper"
ALIAS_FILE="$HOME/.coppa_aliases"

echo "🚀 Setting up CoPPA Development Helper for global use..."

# Check if we're in the CoPPA repository
if [ ! -d "$MCP_DIR" ]; then
    echo "❌ Error: Could not find MCP server directory at $MCP_DIR"
    echo "Make sure you're running this from within the CoPPA repository."
    exit 1
fi

# Create alias file
cat > "$ALIAS_FILE" << EOF
#!/bin/bash
# CoPPA Development Helper Aliases
# Generated on $(date)

# Navigate to CoPPA MCP server and run command
coppa-dev() {
    local current_dir="\$(pwd)"
    cd "$MCP_DIR"
    ./coppa-dev "\$@"
    cd "\$current_dir"
}

# Quick aliases for common commands
coppa-component() {
    coppa-dev component "\$1"
}

coppa-route() {
    coppa-dev route "\$1" "\$2"
}

coppa-interface() {
    coppa-dev interface "\$1"
}

coppa-form() {
    coppa-dev form "\$1"
}

coppa-security() {
    coppa-dev security-check
}

coppa-a11y() {
    coppa-dev accessibility-check
}

# MCP server management
coppa-server-start() {
    coppa-dev start
}

coppa-server-stop() {
    coppa-dev stop
}

coppa-server-status() {
    coppa-dev status
}

coppa-server-logs() {
    coppa-dev logs
}

EOF

# Add to shell profile if not already there
SHELL_PROFILE=""
if [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.profile" ]; then
    SHELL_PROFILE="$HOME/.profile"
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "source $ALIAS_FILE" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# CoPPA Development Helper" >> "$SHELL_PROFILE"
        echo "source $ALIAS_FILE" >> "$SHELL_PROFILE"
        echo "✅ Added CoPPA aliases to $SHELL_PROFILE"
    else
        echo "✅ CoPPA aliases already configured in $SHELL_PROFILE"
    fi
fi

# Make the alias file executable
chmod +x "$ALIAS_FILE"

echo ""
echo "🎉 Global setup complete!"
echo ""
echo "🔄 To start using the commands, either:"
echo "   1. Restart your terminal, or"
echo "   2. Run: source $ALIAS_FILE"
echo ""
echo "📝 Available global commands:"
echo "   coppa-dev <command>        - Run any MCP server command"
echo "   coppa-component <name>     - Generate React component"
echo "   coppa-route <name> <path>  - Generate Flask route"
echo "   coppa-interface <name>     - Generate TypeScript interface"
echo "   coppa-form <name>          - Generate accessible form"
echo "   coppa-security             - Run security check"
echo "   coppa-a11y                 - Run accessibility check"
echo "   coppa-server-start         - Start MCP server"
echo "   coppa-server-stop          - Stop MCP server"
echo "   coppa-server-status        - Check server status"
echo "   coppa-server-logs          - View server logs"
echo ""
echo "💡 Examples:"
echo "   coppa-component IncidentReport"
echo "   coppa-route create_incident /api/incidents"
echo "   coppa-interface PoliceData"
echo "   coppa-server-start"
echo ""
echo "📍 You can run these commands from anywhere in your CoPPA project!"
