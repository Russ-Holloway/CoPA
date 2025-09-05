# CoPPA Development Helper - Integration Guide

## Quick Start Examples

### 1. Creating a New Police Report Component

**Step 1: Generate the component using MCP server**
```bash
cd mcp-servers/coppa-dev-helper
echo 'generate_react_component {
  "componentName": "PoliceReport", 
  "props": [
    {"name": "reportId", "type": "string", "optional": false},
    {"name": "officerId", "type": "string", "optional": false},
    {"name": "onSave", "type": "(report: PoliceReportData) => Promise<void>", "optional": false},
    {"name": "readOnly", "type": "boolean", "optional": true}
  ],
  "useFluentUI": true,
  "isAccessible": true,
  "includeTests": true
}' | npm start
```

**Step 2: Place generated files in CoPPA structure**
```bash
# Create the component directory
mkdir -p frontend/src/components/PoliceReport

# Copy generated files (modify paths as needed)
# PoliceReport.tsx -> frontend/src/components/PoliceReport/
# PoliceReport.module.css -> frontend/src/components/PoliceReport/
# PoliceReport.test.tsx -> frontend/src/components/PoliceReport/
# index.ts -> frontend/src/components/PoliceReport/
```

**Step 3: Integrate with CoPPA patterns**
```typescript
// Update PoliceReport.tsx to use CoPPA context
import { useContext } from 'react';
import { AppStateContext } from '../../state/AppProvider';

// Add authentication check
const appStateContext = useContext(AppStateContext);
const ui = appStateContext?.state.frontendSettings?.ui;
```

### 2. Creating a Secure Flask Route

**Step 1: Generate the route**
```bash
echo 'create_flask_route {
  "routeName": "submit_police_report",
  "path": "/api/reports",
  "methods": ["POST"],
  "requiresAuth": true,
  "requiresCosmosDB": true,
  "description": "Submit a new police report with proper authentication and logging"
}' | npm start
```

**Step 2: Add to app.py**
```python
# Add the generated route code to app.py
# Remember to:
# 1. Add proper input validation
# 2. Implement business logic
# 3. Add error handling
# 4. Test with authenticated users
```

### 3. Adding TypeScript Types

**Step 1: Generate interface**
```bash
echo 'create_typescript_interface {
  "interfaceName": "PoliceReportData",
  "fields": [
    {"name": "id", "type": "string", "optional": false},
    {"name": "reportType", "type": "ReportType", "optional": false},
    {"name": "incidentDate", "type": "Date", "optional": false},
    {"name": "location", "type": "string", "optional": false},
    {"name": "description", "type": "string", "optional": false},
    {"name": "officerId", "type": "string", "optional": false},
    {"name": "status", "type": "ReportStatus", "optional": false}
  ],
  "description": "Interface for police report data structure"
}' | npm start
```

**Step 2: Add to models.ts**
```typescript
// Add to frontend/src/api/models.ts
export interface PoliceReportData {
  // Generated interface code here
}

// Add related enums
export enum ReportType {
  INCIDENT = 'incident',
  TRAFFIC = 'traffic',
  CRIME = 'crime',
  DOMESTIC = 'domestic'
}

export enum ReportStatus {
  DRAFT = 'draft',
  SUBMITTED = 'submitted',
  UNDER_REVIEW = 'under_review',
  APPROVED = 'approved',
  CLOSED = 'closed'
}
```

## Development Workflow Integration

### 1. Component Development
```bash
# 1. Generate component structure
mcp-server generate_react_component {...}

# 2. Add to CoPPA component library
cp generated-files frontend/src/components/

# 3. Check accessibility compliance
mcp-server check_accessibility_compliance {...}

# 4. Add to component exports
echo "export * from './NewComponent';" >> frontend/src/components/index.ts
```

### 2. API Development
```bash
# 1. Generate Flask route
mcp-server create_flask_route {...}

# 2. Add TypeScript types
mcp-server generate_api_types {...}

# 3. Create React hook
mcp-server create_api_hook {...}

# 4. Add security validation
mcp-server add_input_validation {...}
```

### 3. Security Review
```bash
# Regular security checks
mcp-server check_security_patterns {"language": "typescript", "context": "frontend"}
mcp-server check_security_patterns {"language": "python", "context": "backend"}
mcp-server check_sensitive_data_handling {"dataType": "police"}
```

## Best Practices

### 1. Always Generate Accessible Components
```bash
# Always include accessibility flags
"isAccessible": true,
"wcagLevel": "AA"
```

### 2. Security First Development
```bash
# Always require authentication for police data
"requiresAuth": true,
"requiresCosmosDB": true
```

### 3. Consistent Naming
- Use PascalCase for React components: `PoliceReport`
- Use camelCase for functions and variables: `submitPoliceReport`
- Use kebab-case for URLs: `/api/police-reports`
- Follow PDS naming conventions for resources

### 4. Type Safety
- Generate TypeScript interfaces for all data structures
- Use strict TypeScript configuration
- Add proper error handling types

## Testing Integration

### Generated Test Files
The MCP server generates test files that integrate with CoPPA's testing setup:

```typescript
// Example generated test
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { PoliceReport } from './PoliceReport';

describe('PoliceReport', () => {
  it('renders without crashing', () => {
    render(<PoliceReport reportId="123" officerId="456" onSave={jest.fn()} />);
    expect(screen.getByRole('region')).toBeInTheDocument();
  });

  it('is accessible', () => {
    const { container } = render(<PoliceReport reportId="123" officerId="456" onSave={jest.fn()} />);
    expect(container.firstChild).toHaveAttribute('aria-label');
  });
});
```

Run tests:
```bash
cd frontend && npm test
```

## Deployment Considerations

### 1. Security Validation
Before deploying any generated code:
- Run security pattern analysis
- Validate input handling
- Check for sensitive data exposure
- Test authentication flows

### 2. Accessibility Testing
- Test with screen readers (NVDA recommended for UK public sector)
- Verify keyboard navigation
- Check color contrast ratios
- Test mobile responsiveness

### 3. Performance
- Generated CSS modules are optimized for performance
- Components follow React best practices
- API endpoints include proper error handling

## Troubleshooting

### Common Issues

**1. TypeScript Errors**
```bash
# Regenerate types with proper configuration
mcp-server create_typescript_interface {...}
```

**2. Authentication Issues**
```bash
# Ensure proper authentication patterns
mcp-server add_route_authentication {...}
```

**3. Accessibility Failures**
```bash
# Check and fix accessibility issues
mcp-server check_accessibility_compliance {...}
mcp-server add_aria_labels {...}
```

## Advanced Usage

### Custom Validation Rules
```bash
echo 'add_input_validation {
  "fieldName": "policeForceCode", 
  "fieldType": "text",
  "validationRules": ["Must be 3 characters", "Uppercase letters only", "Must be valid UK force code"],
  "context": "police_data"
}' | npm start
```

### Accessible Form Generation
```bash
echo 'generate_accessible_form {
  "formName": "IncidentReport",
  "fields": [
    {"name": "incidentType", "type": "select", "label": "Incident Type", "required": true},
    {"name": "location", "type": "text", "label": "Location", "required": true},
    {"name": "description", "type": "textarea", "label": "Description", "required": true}
  ],
  "includeValidation": true,
  "includeErrorHandling": true
}' | npm start
```

This MCP server accelerates CoPPA development while maintaining security, accessibility, and code quality standards.
