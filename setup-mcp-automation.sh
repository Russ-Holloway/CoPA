#!/bin/bash

# MCP Server Auto-Integration Script for VS Code
# Automatically configures Copilot to consider MCP servers for every interaction

echo "🤖 Setting up MCP Server Auto-Integration..."

# Create VS Code workspace settings to enhance MCP integration
cat > .vscode/settings.json << 'EOF'
{
  "github.copilot.chat.welcomeMessage": "CoPPA Development Assistant Ready! 🚔\n\n🔧 Available MCP Servers:\n• coppa-component <name> - Generate accessible React components\n• coppa-api <endpoint> - Create secure Flask APIs\n• arm-validate <file> - Validate Azure templates\n• arm-web-identity - Fix identity references\n\n💡 Tip: Add '**search Microsoft docs**' to queries for official guidance",
  
  "github.copilot.chat.localeOverride": "en-GB",
  
  "github.copilot.advanced": {
    "debug.overrideEngine": "copilot-chat",
    "debug.testOverrideProxyUrl": "https://copilot-proxy.githubusercontent.com",
    "debug.filterLogCategories": []
  },
  
  "mcp.servers.autoStart": true,
  "mcp.servers.coppa-dev-helper.enabled": true,
  "mcp.servers.azure-arm-helper.enabled": true,
  "mcp.servers.microsoft.docs.mcp.enabled": true,
  
  "editor.inlineSuggest.enabled": true,
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "plaintext": true,
    "markdown": true,
    "json": true,
    "bicep": true
  }
}
EOF

# Create enhanced MCP integration aliases
cat >> ~/.bashrc << 'EOF'

# CoPPA MCP Server Integration Aliases
export COPPA_MCP_ENABLED=true

# Enhanced MCP aliases with auto-prompting
alias mcp-help='echo "🤖 CoPPA MCP Servers:"; echo "• coppa-component <name> - Generate React component"; echo "• coppa-api <endpoint> - Create Flask API"; echo "• coppa-form <name> - Create accessible form"; echo "• arm-validate <file> - Validate ARM template"; echo "• arm-web-identity - Fix identity issues"; echo ""; echo "💡 In VS Code: Ask Copilot + add \"**search Microsoft docs**\""'

# Auto-suggest MCP usage based on context
coppa-smart() {
    local cmd="$1"
    local context="$2"
    
    case "$cmd" in
        "component"|"react"|"tsx")
            echo "💡 Suggestion: Use 'coppa-component $context' for accessible React component"
            ;;
        "api"|"flask"|"endpoint")
            echo "💡 Suggestion: Use 'coppa-api $context' for secure Flask API"
            ;;
        "azure"|"arm"|"bicep")
            echo "💡 Suggestion: Use 'arm-validate $context' for infrastructure validation"
            ;;
        *)
            echo "💡 Available: coppa-component, coppa-api, arm-validate, arm-web-identity"
            ;;
    esac
}

# Auto-integration function for common development tasks
coppa-dev() {
    echo "🚔 CoPPA Development Assistant"
    echo "What are you working on? (component/api/infrastructure/docs)"
    read -r task
    
    case "$task" in
        "component"|"react"|"tsx")
            echo "Enter component name:"
            read -r name
            coppa-component "$name"
            ;;
        "api"|"flask"|"endpoint")
            echo "Enter API endpoint name:"
            read -r endpoint
            coppa-api "$endpoint"
            ;;
        "infrastructure"|"azure"|"arm")
            echo "Enter ARM template file path:"
            read -r file
            arm-validate "$file"
            ;;
        "docs"|"documentation")
            echo "💡 In VS Code Copilot: Ask your question + add '**search Microsoft docs**'"
            ;;
        *)
            mcp-help
            ;;
    esac
}

EOF

# Create VS Code task for MCP integration
mkdir -p .vscode
cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "MCP: Generate Component",
            "type": "shell",
            "command": "coppa-component",
            "args": ["${input:componentName}"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "MCP: Validate ARM Template",
            "type": "shell",
            "command": "arm-validate",
            "args": ["${file}"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "MCP: Create API Endpoint",
            "type": "shell",
            "command": "coppa-api",
            "args": ["${input:apiName}"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ],
    "inputs": [
        {
            "id": "componentName",
            "description": "Component name (e.g., UserProfile, IncidentForm)",
            "default": "MyComponent",
            "type": "promptString"
        },
        {
            "id": "apiName",
            "description": "API endpoint name (e.g., login, search, report)",
            "default": "endpoint",
            "type": "promptString"
        }
    ]
}
EOF

# Create keyboard shortcuts for MCP integration
cat > .vscode/keybindings.json << 'EOF'
[
    {
        "key": "ctrl+shift+m c",
        "command": "workbench.action.tasks.runTask",
        "args": "MCP: Generate Component"
    },
    {
        "key": "ctrl+shift+m a",
        "command": "workbench.action.tasks.runTask", 
        "args": "MCP: Create API Endpoint"
    },
    {
        "key": "ctrl+shift+m v",
        "command": "workbench.action.tasks.runTask",
        "args": "MCP: Validate ARM Template"
    },
    {
        "key": "ctrl+shift+m h",
        "command": "workbench.action.terminal.sendSequence",
        "args": {
            "text": "mcp-help\n"
        }
    }
]
EOF

echo "✅ MCP Auto-Integration Setup Complete!"
echo ""
echo "🎯 How to Use:"
echo "• Terminal: 'coppa-dev' for interactive assistant"
echo "• VS Code: Ctrl+Shift+M then C/A/V/H for MCP commands"
echo "• Copilot: Add '**search Microsoft docs**' to queries"
echo "• Commands: coppa-component, coppa-api, arm-validate, arm-web-identity"
echo ""
echo "🔄 Reload VS Code to activate all integrations"
