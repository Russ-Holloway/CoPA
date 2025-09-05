# CoPPA Copilot Instructions

## 🚔 Project: Police Chat App
Python Flask + TypeScript/React. Sensitive data. WCAG 2.1 AA + enterprise security required.

## 🎯 Core Rules
1. **MINIMAL CHANGES** - Only modify what's needed
2. **MCP FIRST** - Use `coppa-component`, `coppa-api`, `arm-validate` before coding
3. **PRESERVE PATTERNS** - Follow existing code style
4. **ONE TASK** - Complete request fully, then stop
5. **CLEAN UP** - Remove backup/duplicate files after changes
6. **SECURITY + A11Y** - Police data standards + WCAG 2.1 AA

## ⚡ MCP Commands
```bash
coppa-component LoginForm    # React component
coppa-api authenticate       # Flask API  
arm-validate main.bicep      # Azure template
arm-web-identity            # Fix identity errors
```
💡 Add "**search Microsoft docs**" to Copilot queries for official guidance

## 🛠️ Workflow
1. **Clarify exact task**
2. **Check MCP servers first**  
3. **Make minimal changes**
4. **Test and verify**
5. **Clean up** - Remove backup/duplicate files created during changes
6. **Stop when complete**

## 🔒 Security Essentials
- Never log sensitive police data
- Sanitize all inputs
- Use environment variables for secrets
- HTTPS for all data transmission

## ♿ Accessibility Essentials  
- Semantic HTML elements
- Keyboard navigation support
- 4.5:1 color contrast minimum
- Screen reader compatibility

## 🎯 Before Every Change
- What exactly needs changing?
- Which files are in-scope?
- Can MCP handle this?
- What's the minimal change needed?
