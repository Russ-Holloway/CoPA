# CoPPA Development Helper MCP Server

A specialized Model Context Protocol (MCP) server designed specifically for CoPPA (College of Policing Assistant) feature development. This server provides intelligent assistance for React/TypeScript frontend and Python Flask backend development with a focus on accessibility, security, and police-specific requirements.

## Overview

The CoPPA Dev Helper MCP Server addresses the unique challenges of developing police software applications by providing:

- **React/TypeScript Component Generation**: WCAG 2.1 AA compliant components
- **Flask Route Development**: Secure, authenticated API endpoints
- **Type Safety**: Comprehensive TypeScript interface generation
- **Accessibility Compliance**: Built-in accessibility checking and remediation
- **Security Patterns**: Police data protection and GDPR compliance
- **Best Practices**: CoPPA-specific development guidelines

## Features

### 🔧 React/Frontend Development
- **generate_react_component**: Create accessible React components with FluentUI integration
- **add_component_props**: Add type-safe props to existing components
- **create_api_hook**: Generate custom React hooks for API integration
- **generate_css_module**: Create responsive, accessible CSS modules

### 🛡️ Flask/Backend Development
- **create_flask_route**: Generate secure Flask routes with authentication
- **add_route_authentication**: Add CoPPA authentication patterns to routes
- **create_api_model**: Create data models with validation
- **add_cosmos_db_integration**: Add CosmosDB CRUD operations

### 📝 TypeScript Development
- **create_typescript_interface**: Generate type-safe interfaces
- **add_type_definitions**: Add custom type definitions
- **generate_api_types**: Create API request/response types

### ♿ Accessibility (WCAG 2.1 AA)
- **check_accessibility_compliance**: Audit components for accessibility
- **add_aria_labels**: Generate appropriate ARIA attributes
- **generate_accessible_form**: Create fully accessible forms

### 🔒 Security (Police Data Protection)
- **check_security_patterns**: Analyze code for security vulnerabilities
- **add_input_validation**: Generate client and server-side validation
- **check_sensitive_data_handling**: Ensure proper police data protection

## Installation & Setup

1. **Navigate to the server directory**:
   ```bash
   cd mcp-servers/coppa-dev-helper
   ```

2. **Install Dependencies**:
   ```bash
   npm install
   ```

3. **Build the Server**:
   ```bash
   npm run build
   ```

4. **Run the Server**:
   ```bash
   npm start
   ```

## Usage Examples

### Generate a React Component
```bash
echo 'generate_react_component {"componentName": "IncidentReport", "props": [{"name": "incidentId", "type": "string", "required": true}, {"name": "onSave", "type": "(data: IncidentData) => void", "required": true}], "useFluentUI": true, "isAccessible": true}' | npm start
```

### Create a Flask Route
```bash
echo 'create_flask_route {"routeName": "create_incident", "path": "/api/incidents", "methods": ["POST"], "requiresAuth": true, "requiresCosmosDB": true}' | npm start
```

### Generate TypeScript Interface
```bash
echo 'create_typescript_interface {"interfaceName": "IncidentData", "fields": [{"name": "id", "type": "string"}, {"name": "description", "type": "string", "optional": false}, {"name": "location", "type": "string"}]}' | npm start
```

### Check Accessibility Compliance
```bash
echo 'check_accessibility_compliance {"componentType": "form", "wcagLevel": "AA"}' | npm start
```

### Validate Security Patterns
```bash
echo 'check_security_patterns {"language": "typescript", "context": "frontend"}' | npm start
```

## CoPPA-Specific Features

### Police Data Protection
- Automatic compliance checks for GDPR and Police Data Protection Act 2018
- Secure handling of sensitive police information
- Data minimization and retention policy enforcement
- Audit logging for all data access

### Accessibility for Emergency Services
- High contrast mode support for operational environments
- Keyboard shortcuts for critical functions
- Screen reader optimization for emergency situations
- Mobile-first responsive design for field operations

### Security Best Practices
- Multi-factor authentication integration
- Role-based access control patterns
- Secure session management
- Input validation and sanitization
- SQL injection and XSS prevention

### UK Government Standards
- NCSC (National Cyber Security Centre) compliance
- PDS (Police Digital Service) naming conventions
- GOV.UK design system integration
- Digital by Default principles

## API Methods

| Category | Method | Purpose |
|----------|--------|---------|
| **React** | `generate_react_component` | Create accessible React components |
| **React** | `add_component_props` | Add type-safe props |
| **React** | `create_api_hook` | Generate API integration hooks |
| **React** | `generate_css_module` | Create responsive CSS |
| **Flask** | `create_flask_route` | Generate secure API endpoints |
| **Flask** | `add_route_authentication` | Add authentication patterns |
| **Flask** | `create_api_model` | Create data models |
| **Flask** | `add_cosmos_db_integration` | Add database operations |
| **TypeScript** | `create_typescript_interface` | Generate interfaces |
| **TypeScript** | `add_type_definitions` | Add type definitions |
| **TypeScript** | `generate_api_types` | Create API types |
| **Accessibility** | `check_accessibility_compliance` | Audit accessibility |
| **Accessibility** | `add_aria_labels` | Generate ARIA attributes |
| **Accessibility** | `generate_accessible_form` | Create accessible forms |
| **Security** | `check_security_patterns` | Security analysis |
| **Security** | `add_input_validation` | Generate validation |
| **Security** | `check_sensitive_data_handling` | Data protection audit |

## Development Guidelines

### Code Quality Standards
- **Simplicity First**: Always choose the simplest solution that meets requirements
- **Type Safety**: Use TypeScript strict mode throughout
- **Accessibility**: WCAG 2.1 AA compliance is mandatory
- **Security**: Police data protection is paramount
- **Testing**: Comprehensive testing for all generated code

### CoPPA Integration Patterns
- Follow existing authentication patterns in `backend/auth/`
- Use established API patterns from `frontend/src/api/`
- Integrate with existing state management in `AppProvider`
- Follow CSS module patterns in existing components

### Security Considerations
- Never log sensitive police data
- Use parameterized queries for all database operations
- Implement proper input validation on both client and server
- Follow principle of least privilege for all access controls
- Regular security audits and penetration testing

## Benefits

- **Faster Development**: Generate boilerplate code following CoPPA patterns
- **Consistency**: Standardized components and APIs across the application
- **Accessibility**: Built-in WCAG 2.1 AA compliance
- **Security**: Police data protection by default
- **Quality Assurance**: Automated best practice enforcement
- **Learning Tool**: Understand CoPPA development patterns

## Contributing

This MCP server is designed to evolve with CoPPA development needs. When adding new features:

1. Follow existing helper class patterns
2. Include comprehensive security checks
3. Ensure accessibility compliance
4. Add appropriate documentation
5. Test with real CoPPA scenarios

## Support

For questions about this MCP server or CoPPA development:
- Review CoPPA documentation in `docs/`
- Check existing patterns in the CoPPA codebase
- Follow security guidelines in `security/`

---

*Built specifically for the CoPPA project to accelerate secure, accessible police software development.*
