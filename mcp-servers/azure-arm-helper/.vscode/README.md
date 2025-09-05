# VS Code Integration for Azure ARM Helper

## Overview
This folder contains VS Code specific configuration for the Azure ARM Helper MCP Server, providing seamless development and debugging experience.

## Files Included

### tasks.json
Pre-configured VS Code tasks for common ARM helper operations:
- **ARM Helper: Build** - Compile TypeScript to JavaScript
- **ARM Helper: Start Server** - Launch the MCP server interactively
- **ARM Helper: Test Identity Fix** - Quick test of identity reference fixing
- **ARM Helper: Test Role Pattern** - Test role assignment pattern generation
- **ARM Helper: Validate Template** - Validate currently open ARM/Bicep template
- **ARM Helper: Check Best Practices** - Run best practices check on current file

### launch.json
Debug configuration for the ARM Helper server:
- Full TypeScript debugging support with source maps
- Integrated terminal for interactive debugging
- Environment setup for development mode

### extensions.json
Recommended VS Code extensions for ARM development:
- Azure Resource Manager Tools
- Bicep language support
- Azure Account integration
- TypeScript enhanced support

### settings.json
Optimized settings for ARM/Bicep development:
- TypeScript import preferences
- Bicep file associations and features
- Azure resource grouping preferences

## Usage

### Running Tasks
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type "Tasks: Run Task"
3. Select any ARM Helper task

### Debugging
1. Open `src/index.ts`
2. Set breakpoints as needed
3. Press `F5` or go to Run & Debug panel
4. Select "Debug ARM Helper Server"

### Quick Testing
- Use `Ctrl+Shift+P` → "Tasks: Run Task" → "ARM Helper: Test Identity Fix"
- Or open a `.bicep` file and run "ARM Helper: Validate Template"

### File Validation
When editing ARM/Bicep templates:
1. Open the template file
2. Run task "ARM Helper: Validate Template" (validates current file)
3. Run task "ARM Helper: Check Best Practices" for recommendations

This VS Code integration makes ARM development faster and more reliable within the CoPPA project workflow.
