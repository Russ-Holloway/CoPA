#!/bin/bash
# CoPPA Dev Helper MCP Server - Quick Setup Script

set -e

echo "🚀 Setting up CoPPA Development Helper MCP Server for regular use..."

# Navigate to the MCP server directory
cd "$(dirname "$0")"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "📦 Installing dependencies..."
npm install

echo "🔨 Building the server..."
npm run build

echo "✅ Setup complete!"
echo ""
echo "🎯 Usage Options:"
echo ""
echo "1. Interactive Mode:"
echo "   npm start"
echo ""
echo "2. Single Command Mode:"
echo "   echo 'method_name {\"param\": \"value\"}' | npm start"
echo ""
echo "3. Background Service (recommended for regular use):"
echo "   npm run service:start"
echo ""
echo "4. VS Code Integration:"
echo "   Open this folder in VS Code and use F5 to debug"
echo ""
echo "📚 Documentation:"
echo "   - README.md - Full server documentation"
echo "   - INTEGRATION_GUIDE.md - How to integrate with CoPPA"
echo "   - demo.sh - Example commands"
echo ""
echo "🔧 Development Commands:"
echo "   npm run dev     - Run in development mode with auto-reload"
echo "   npm test        - Run tests (when added)"
echo "   npm run clean   - Clean build directory"
echo ""
