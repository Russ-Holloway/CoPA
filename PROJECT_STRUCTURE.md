# CoPPA Project Structure

This document outlines the organized structure of the CoPPA (Community Oriented Police Partnership Application) repository.

## 📁 Repository Organization

### 🚀 **Quick Start**
- `README.md` - Main project overview and getting started guide
- `azure.yaml` - Azure Developer CLI configuration
- `app.py` - Main Flask application entry point

### 🏗️ **Core Application**
```
├── frontend/          # React/TypeScript web application
├── backend/           # Python Flask backend services
├── static/           # Static web assets
└── data/             # Sample data and documentation
```

### 🛠️ **Development & Deployment**
```
├── deployment/
│   ├── azure/        # Azure infrastructure (Bicep & ARM templates)
│   ├── docker/       # Docker configuration files
│   └── scripts/      # Deployment automation scripts
├── scripts/          # Data processing and utility scripts
└── tests/           # Application test suites
```

### 📚 **Documentation**
```
├── docs/
│   ├── deployment/   # Deployment guides and procedures
│   ├── development/  # Development setup and guides
│   └── user/         # End-user documentation
```

### 🔒 **Security**
```
├── security/
│   ├── tools/        # Security scanning and validation tools
│   ├── SECURITY.md   # Security policy and procedures
│   └── *.yaml        # Security configuration files
```

### ⚙️ **Configuration**
```
├── .github/          # GitHub workflows and templates
├── .vscode/          # VS Code development settings
├── .devcontainer/    # Development container configuration
└── requirements.txt  # Python dependencies
```

## 🗂️ **Detailed Directory Guide**

### **Frontend (`frontend/`)**
React/TypeScript application with modern tooling:
- `src/` - Source code (components, services, utilities)
- `public/` - Static assets served directly
- `package.json` - Node.js dependencies and scripts

### **Backend (`backend/`)**
Python Flask backend services:
- `auth/` - Authentication and authorization
- `history/` - Chat history management
- `security/` - Security utilities and middleware

### **Deployment (`deployment/`)**
All deployment-related files organized by type:
- `azure/` - Infrastructure as Code (Bicep/ARM templates)
- `docker/` - Container configuration
- `scripts/` - Automated deployment scripts

### **Security (`security/`)**
Centralized security management:
- `tools/` - Security scanning and validation scripts
- Configuration files for security policies
- Security documentation and reports

### **Scripts (`scripts/`)**
Data processing and utility scripts:
- Document processing and indexing
- Search index management
- Configuration utilities

### **Documentation (`docs/`)**
Organized by audience and purpose:
- `deployment/` - Azure deployment guides
- `development/` - Developer setup and API docs
- `user/` - End-user guides and customization

## 🎯 **Navigation Guide**

### **For Developers**
1. Start with `README.md` for project overview
2. Check `frontend/` and `backend/` for application code
3. Review `docs/development/` for setup guides
4. Use `tests/` for testing procedures

### **For DevOps/Deployment**
1. Review `deployment/azure/` for infrastructure
2. Check `deployment/scripts/` for automation
3. Reference `docs/deployment/` for procedures
4. Monitor `security/` for compliance

### **For Security Teams**
1. Review `security/SECURITY.md` for policies
2. Use `security/tools/` for scanning
3. Check security configuration files
4. Reference security documentation

### **For End Users**
1. Start with `README.md` for basic information
2. Check `docs/user/` for customization guides
3. Review `data/` for sample content

## 🔄 **Maintenance**

This structure is designed for:
- **Clear separation of concerns**
- **Easy navigation and discovery**
- **Consistent organization patterns**
- **Scalable growth as project evolves**

## 📋 **File Count Summary**
- **Total files**: ~291 (after cleanup)
- **Organized into**: 8 main categories
- **Documentation**: Properly categorized by audience
- **Security**: Centralized and easily auditable
