# CoPPA Development Helper - VS Code Integration

## Overview
This directory contains VS Code workspace settings and tasks for seamless integration with the CoPPA Development Helper MCP Server.

## Quick Setup for VS Code

### 1. Open in VS Code
```bash
cd mcp-servers/coppa-dev-helper
code .
```

### 2. Available VS Code Tasks (Ctrl+Shift+P > "Tasks: Run Task")

- **Build MCP Server** - Compiles TypeScript to JavaScript
- **Start MCP Server** - Runs the server interactively
- **Dev Mode** - Runs with auto-reload for development

### 3. Debug Configuration (F5)
- Pre-configured debug launch for the MCP server
- Automatic build before debugging
- Integrated terminal for input/output

### 4. Extensions Recommended

Install these VS Code extensions for optimal development:

```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-vscode.vscode-eslint"
  ]
}
```

### 5. Keyboard Shortcuts

Add these to your VS Code settings for quick access:

```json
{
  "key": "ctrl+shift+m",
  "command": "workbench.action.tasks.runTask",
  "args": "start"
},
{
  "key": "ctrl+shift+b",
  "command": "workbench.action.tasks.runTask", 
  "args": "build"
}
```

## Workspace Integration

### CoPPA Project Integration
When working on the main CoPPA project, you can:

1. **Open both workspaces**: Main CoPPA + MCP Server
2. **Use integrated terminal** to run MCP commands
3. **Copy generated code** directly into CoPPA components

### Multi-root Workspace Setup
Create a `.vscode/coppa-workspace.code-workspace` file:

```json
{
  "folders": [
    {
      "name": "CoPPA Main",
      "path": "../.."
    },
    {
      "name": "MCP Dev Helper", 
      "path": "."
    }
  ],
  "settings": {
    "typescript.preferences.includePackageJsonAutoImports": "on"
  }
}
```

## Development Workflow

### 1. Component Development
```bash
# In VS Code terminal
./coppa-dev component MyNewComponent

# Copy output to CoPPA frontend
cp generated-files ../../../frontend/src/components/
```

### 2. Backend Route Development  
```bash
# Generate route
./coppa-dev route my_new_route /api/my-endpoint

# Add to app.py in main CoPPA project
```

### 3. TypeScript Integration
```bash
# Generate interfaces
./coppa-dev interface MyDataInterface

# Add to frontend/src/api/models.ts
```

## Debugging Tips

### 1. Debug MCP Server
- Set breakpoints in TypeScript files
- Use F5 to start debugging
- Input commands in Debug Console

### 2. Log Output
```bash
# View server logs
npm run logs

# Check service status  
npm run service:status
```

### 3. Quick Testing
```bash
# Test functionality
npm run quick-test

# Or use the coppa-dev wrapper
./coppa-dev test
```

## Troubleshooting

### Common Issues

**TypeScript Errors:**
- Run `npm run rebuild` 
- Check tsconfig.json configuration
- Ensure all dependencies are installed

**Server Won't Start:**
- Check if port is already in use
- Verify Node.js version (18+ recommended)
- Run `./setup.sh` to reinstall dependencies

**VS Code Integration Issues:**
- Reload VS Code window (Ctrl+Shift+P > "Developer: Reload Window")
- Check VS Code tasks are properly configured
- Verify workspace trust settings

### Performance Tips

- Use `npm run dev` for development with auto-reload
- Keep MCP server running as background service during active development
- Use VS Code's integrated terminal for faster workflow

## Advanced Usage

### Custom Commands in VS Code

Add to `.vscode/tasks.json`:

```json
{
  "label": "Generate Police Component",
  "type": "shell",
  "command": "./coppa-dev component ${input:componentName}",
  "group": "build",
  "presentation": {
    "echo": true,
    "reveal": "always"
  }
}
```

### Snippets for Common Patterns

Create `.vscode/snippets.json`:

```json
{
  "mcp-component": {
    "prefix": "mcp-comp",
    "body": [
      "./coppa-dev component $1"
    ],
    "description": "Generate MCP component"
  }
}
```
