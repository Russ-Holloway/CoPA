# 🚀 CoPPA Development Helper - Quick Start Guide

## One-Time Setup (5 minutes)

### 1. **Initial Setup**
```bash
cd mcp-servers/coppa-dev-helper
./setup.sh
```

### 2. **Global Installation (Optional but Recommended)**
```bash
./install-global.sh
source ~/.bashrc  # or restart terminal
```

### 3. **Test Installation**
```bash
coppa-dev test
# or if not using global install:
./coppa-dev test
```

## 🎯 Daily Usage

### **Quick Commands** (after global install):

```bash
# Generate React component
coppa-component IncidentReport

# Generate Flask route  
coppa-route create_incident /api/incidents

# Generate TypeScript interface
coppa-interface PoliceReportData

# Generate accessible form
coppa-form IncidentReportForm

# Security check
coppa-security

# Accessibility check  
coppa-a11y
```

### **Server Management**:

```bash
# Start server (runs in background)
coppa-server-start

# Check if running
coppa-server-status

# View logs
coppa-server-logs

# Stop server
coppa-server-stop
```

## 📋 Common Development Workflows

### **1. New Feature Component**
```bash
# Generate the component
coppa-component IncidentReport

# Copy to CoPPA frontend
cp IncidentReport.tsx ../../frontend/src/components/IncidentReport/
cp IncidentReport.module.css ../../frontend/src/components/IncidentReport/
cp IncidentReport.test.tsx ../../frontend/src/components/IncidentReport/
```

### **2. New API Endpoint**
```bash
# Generate secure Flask route
coppa-route create_incident /api/incidents

# Add generated code to app.py in main CoPPA project
# Remember to add business logic and validation
```

### **3. Type Definitions**
```bash
# Generate TypeScript interface
coppa-interface IncidentData

# Add to frontend/src/api/models.ts
```

### **4. Accessible Forms**
```bash
# Generate complete accessible form
coppa-form IncidentReportForm

# Includes validation, error handling, and ARIA attributes
```

## 🔧 Development Environment

### **VS Code Integration**
```bash
# Open MCP server in VS Code for development
cd mcp-servers/coppa-dev-helper
code .

# Use F5 to debug the server
# Use Ctrl+Shift+P > "Tasks: Run Task" for quick actions
```

### **Background Service Mode**
```bash
# Start server as background service (recommended for active development)
coppa-server-start

# Server runs in background, you can continue working
# Check status anytime with:
coppa-server-status
```

## 📚 Integration Examples

### **React Component Integration**
```typescript
// Generated component integrates with CoPPA patterns:
import { useContext } from 'react';
import { AppStateContext } from '../../state/AppProvider';

export const IncidentReport: React.FC<IncidentReportProps> = (props) => {
  const appStateContext = useContext(AppStateContext);
  // Component automatically includes accessibility and security patterns
};
```

### **Flask Route Integration**
```python
# Generated routes follow CoPPA authentication patterns:
@bp.route("/api/incidents", methods=["POST"])
@require_cosmos_db
async def create_incident():
    authenticated_user = get_authenticated_user_details(request_headers=request.headers)
    # Includes logging, validation, and error handling
```

### **TypeScript Integration**
```typescript
// Generated interfaces work with existing CoPPA types:
export interface IncidentData extends BasePoliceData {
  // Type-safe interfaces for all data structures
}
```

## 🛡️ Security & Compliance

### **Built-in Security**
- ✅ Authentication required by default
- ✅ Input validation templates
- ✅ Police data protection patterns
- ✅ GDPR compliance checks
- ✅ Security logging

### **Built-in Accessibility**
- ✅ WCAG 2.1 AA compliance
- ✅ Screen reader optimization  
- ✅ Keyboard navigation
- ✅ High contrast support
- ✅ Mobile-friendly design

## 🔍 Troubleshooting

### **Common Issues**

**Server won't start:**
```bash
# Check if already running
coppa-server-status

# Kill any existing processes
coppa-server-stop

# Reinstall if needed
./setup.sh
```

**Generated code has errors:**
```bash
# Rebuild server
cd mcp-servers/coppa-dev-helper
npm run rebuild

# Test functionality
coppa-dev test
```

**Global commands not working:**
```bash
# Reinstall global aliases
./install-global.sh
source ~/.bashrc
```

## 📞 Getting Help

### **Documentation**
- `README.md` - Full server documentation
- `INTEGRATION_GUIDE.md` - Detailed integration examples
- `.vscode/README.md` - VS Code specific help

### **Commands Help**
```bash
coppa-dev help           # Show all commands
coppa-dev status         # Check server status  
coppa-dev logs          # View recent activity
```

### **Quick Examples**
```bash
./demo.sh               # Run demo commands
coppa-dev test          # Quick functionality test
```

---

## 🎉 You're Ready to Go!

The CoPPA Development Helper is now set up for regular use. It will accelerate your development while maintaining CoPPA's high standards for security, accessibility, and code quality.

**Next Steps:**
1. Try generating your first component: `coppa-component MyTest`
2. Start the background service: `coppa-server-start` 
3. Integrate generated code into your CoPPA features
4. Share this guide with your development team!
