#!/bin/bash
# Azure ARM Helper MCP Server Setup Script

set -e

echo "🚀 Setting up Azure ARM Helper MCP Server..."

# Check if we're in the right directory
if [[ ! -f "package.json" ]] || [[ ! -f "src/index.ts" ]]; then
    echo "❌ Please run this script from the azure-arm-helper directory"
    exit 1
fi

echo "📦 Installing dependencies..."
npm install

echo "🔨 Building TypeScript..."
npm run build

echo "🧪 Testing server functionality..."
timeout 5s npm start <<EOF || true
exit
EOF

echo "✅ Azure ARM Helper MCP Server setup complete!"
echo ""
echo "🎯 Quick test commands:"
echo "   npm start"
echo "   npm run service:start    # Start as background service"
echo "   npm run service:stop     # Stop background service"
echo "   npm run service:status   # Check service status"
echo "   npm run service:logs     # View service logs"
echo ""
echo "🔧 Example usage:"
echo "   echo 'fix_identity_reference {\"resourceType\": \"Microsoft.Web/sites\", \"identityType\": \"SystemAssigned\"}' | npm start"
echo ""
echo "📝 To install global commands, run: ./install-global.sh"
