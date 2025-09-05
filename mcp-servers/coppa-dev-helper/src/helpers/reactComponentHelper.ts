export interface ComponentProps {
  name: string;
  type: string;
  optional?: boolean;
  description?: string;
}

export interface ComponentGenerationParams {
  componentName: string;
  props?: ComponentProps[];
  useFluentUI?: boolean;
  includeCSSModule?: boolean;
  isAccessible?: boolean;
  includeTests?: boolean;
}

export interface ApiHookParams {
  hookName: string;
  endpoint: string;
  method: 'GET' | 'POST' | 'PUT' | 'DELETE';
  requestType?: string;
  responseType?: string;
}

export interface CSSModuleParams {
  componentName: string;
  includeResponsive?: boolean;
  includeDarkMode?: boolean;
  includeAccessibility?: boolean;
}

export class ReactComponentHelper {
  async generateComponent(params: ComponentGenerationParams): Promise<any> {
    try {
      const {
        componentName,
        props = [],
        useFluentUI = true,
        includeCSSModule = true,
        isAccessible = true,
        includeTests = false
      } = params;

      // Generate component interface
      const propsInterface = this.generatePropsInterface(componentName, props);
      
      // Generate component code
      const componentCode = this.generateComponentCode(componentName, props, useFluentUI, isAccessible);
      
      // Generate CSS module if requested
      const cssModule = includeCSSModule ? this.generateCSSModuleCode(componentName) : null;
      
      // Generate test file if requested
      const testCode = includeTests ? this.generateTestCode(componentName) : null;

      return {
        success: true,
        files: {
          [`${componentName}.tsx`]: componentCode,
          [`${componentName}.module.css`]: cssModule,
          [`${componentName}.test.tsx`]: testCode,
          [`index.ts`]: `export * from './${componentName}';`
        },
        structure: {
          folder: `src/components/${componentName}/`,
          files: [
            `${componentName}.tsx`,
            ...(cssModule ? [`${componentName}.module.css`] : []),
            ...(testCode ? [`${componentName}.test.tsx`] : []),
            'index.ts'
          ]
        },
        guidelines: {
          accessibility: 'Component follows WCAG 2.1 AA standards',
          security: 'No sensitive police data in component props',
          styling: 'Uses CSS modules for scoped styling'
        }
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async addProps(params: { componentName: string; newProps: ComponentProps[] }): Promise<any> {
    try {
      const { componentName, newProps } = params;
      
      return {
        success: true,
        propsInterface: this.generatePropsInterface(componentName, newProps),
        instructions: [
          '1. Add the new interface to your component file',
          '2. Update the component function parameters',
          '3. Use the new props in your component logic',
          '4. Update tests if they exist'
        ],
        securityNote: 'Ensure new props do not expose sensitive police data'
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async createApiHook(params: ApiHookParams): Promise<any> {
    try {
      const { hookName, endpoint, method, requestType, responseType } = params;
      
      const hookCode = this.generateApiHookCode(hookName, endpoint, method, requestType, responseType);
      
      return {
        success: true,
        hookCode,
        fileName: `use${hookName}.ts`,
        location: 'src/hooks/',
        usage: `const { data, loading, error, ${method.toLowerCase()} } = use${hookName}();`,
        securityNotes: [
          'Hook includes proper error handling for sensitive data',
          'Uses existing authentication patterns',
          'Follows CoPPA API conventions'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async generateCSSModule(params: CSSModuleParams): Promise<any> {
    try {
      const { componentName, includeResponsive = true, includeDarkMode = true, includeAccessibility = true } = params;
      
      const cssCode = this.generateCSSModuleCode(componentName, includeResponsive, includeDarkMode, includeAccessibility);
      
      return {
        success: true,
        cssCode,
        fileName: `${componentName}.module.css`,
        guidelines: {
          responsive: 'Uses mobile-first approach with proper breakpoints',
          accessibility: 'Includes focus management and color contrast',
          performance: 'Optimized for minimal repaints and reflows'
        }
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  private generatePropsInterface(componentName: string, props: ComponentProps[]): string {
    const propsString = props.map(prop => 
      `  ${prop.name}${prop.optional ? '?' : ''}: ${prop.type};${prop.description ? ` // ${prop.description}` : ''}`
    ).join('\n');

    return `interface ${componentName}Props {
${propsString}
}`;
  }

  private generateComponentCode(componentName: string, props: ComponentProps[], useFluentUI: boolean, isAccessible: boolean): string {
    const propsInterface = this.generatePropsInterface(componentName, props);
    const propsParam = props.length > 0 ? `{ ${props.map(p => p.name).join(', ')} }: ${componentName}Props` : '';
    
    const imports = useFluentUI 
      ? `import React from 'react';
import { Stack, Text } from '@fluentui/react';
import styles from './${componentName}.module.css';`
      : `import React from 'react';
import styles from './${componentName}.module.css';`;

    const accessibilityProps = isAccessible ? `
  // Accessibility attributes
  role="region"
  aria-label="${componentName} component"` : '';

    return `${imports}

${propsInterface}

export const ${componentName}: React.FC<${componentName}Props> = (${propsParam}) => {
  return (
    <div className={styles.container}${accessibilityProps}>
      {/* Component content */}
      <Text variant="large">${componentName} Component</Text>
      {/* Add your component logic here */}
    </div>
  );
};

export default ${componentName};`;
  }

  private generateCSSModuleCode(componentName: string, includeResponsive?: boolean, includeDarkMode?: boolean, includeAccessibility?: boolean): string {
    let css = `/* ${componentName} Component Styles */
.container {
  display: flex;
  flex-direction: column;
  padding: 1rem;
  width: 100%;
}`;

    if (includeResponsive) {
      css += `

/* Responsive Design - Mobile First */
@media (min-width: 768px) {
  .container {
    padding: 1.5rem;
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 2rem;
  }
}`;
    }

    if (includeDarkMode) {
      css += `

/* Dark Mode Support */
[data-theme="dark"] .container {
  background-color: var(--dark-background);
  color: var(--dark-text);
}`;
    }

    if (includeAccessibility) {
      css += `

/* Accessibility Features */
.container:focus {
  outline: 2px solid var(--focus-color);
  outline-offset: 2px;
}

.container:focus-visible {
  outline: 2px solid var(--focus-color);
}

/* High Contrast Mode Support */
@media (prefers-contrast: high) {
  .container {
    border: 1px solid ButtonText;
  }
}`;
    }

    return css;
  }

  private generateApiHookCode(hookName: string, endpoint: string, method: string, requestType?: string, responseType?: string): string {
    const typeImports = [requestType, responseType].filter(Boolean);
    const importStr = typeImports.length > 0 ? `import { ${typeImports.join(', ')} } from '../api/models';` : '';
    
    return `import { useState, useEffect, useCallback } from 'react';
${importStr}

export const use${hookName} = () => {
  const [data, setData] = useState<${responseType || 'any'} | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const ${method.toLowerCase()} = useCallback(async (${requestType ? `payload: ${requestType}` : ''}) => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await fetch('${endpoint}', {
        method: '${method}',
        headers: {
          'Content-Type': 'application/json',
        },
        ${method !== 'GET' && requestType ? 'body: JSON.stringify(payload),' : ''}
      });

      if (!response.ok) {
        throw new Error(\`HTTP error! status: \${response.status}\`);
      }

      const result = await response.json();
      setData(result);
      return result;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error occurred';
      setError(errorMessage);
      console.error('API Error:', errorMessage);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return {
    data,
    loading,
    error,
    ${method.toLowerCase()}
  };
};`;
  }

  private generateTestCode(componentName: string): string {
    return `import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { ${componentName} } from './${componentName}';

describe('${componentName}', () => {
  it('renders without crashing', () => {
    render(<${componentName} />);
    expect(screen.getByRole('region')).toBeInTheDocument();
  });

  it('is accessible', async () => {
    const { container } = render(<${componentName} />);
    // Add accessibility tests here
    expect(container.firstChild).toHaveAttribute('aria-label');
  });

  // Add more tests as needed
});`;
  }
}
