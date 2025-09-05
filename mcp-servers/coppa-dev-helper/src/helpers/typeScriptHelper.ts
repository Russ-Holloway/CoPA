export interface TypeScriptInterfaceParams {
  interfaceName: string;
  fields: InterfaceField[];
  extendsInterface?: string;
  description?: string;
}

export interface InterfaceField {
  name: string;
  type: string;
  optional?: boolean;
  description?: string;
}

export interface ApiTypesParams {
  apiName: string;
  requestType?: string;
  responseType?: string;
  endpoint: string;
  method: string;
}

export class TypeScriptHelper {
  async createInterface(params: TypeScriptInterfaceParams): Promise<any> {
    try {
      const { interfaceName, fields, extendsInterface, description } = params;
      
      const interfaceCode = this.generateInterfaceCode(interfaceName, fields, extendsInterface, description);
      
      return {
        success: true,
        interfaceCode,
        fileName: `${interfaceName}.ts`,
        location: 'frontend/src/types/ or frontend/src/api/models.ts',
        usage: `import { ${interfaceName} } from './types/${interfaceName}';`,
        bestPractices: [
          'Use descriptive property names',
          'Include JSDoc comments for complex types',
          'Follow CoPPA naming conventions',
          'Consider extending base interfaces for common patterns'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async addTypeDefinitions(params: { fileName: string; types: string[] }): Promise<any> {
    try {
      const { fileName, types } = params;
      
      const typeDefinitions = types.map(type => this.generateTypeDefinition(type)).join('\n\n');
      
      return {
        success: true,
        typeDefinitions,
        fileName: `${fileName}.d.ts`,
        location: 'frontend/src/types/',
        instructions: [
          '1. Create or update the .d.ts file',
          '2. Add to tsconfig.json if new file',
          '3. Import in components that need these types',
          '4. Update existing code to use new types'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async generateApiTypes(params: ApiTypesParams): Promise<any> {
    try {
      const { apiName, requestType, responseType, endpoint, method } = params;
      
      const apiTypes = this.generateApiTypesCode(apiName, requestType, responseType, endpoint, method);
      
      return {
        success: true,
        apiTypes,
        fileName: `${apiName}Api.ts`,
        location: 'frontend/src/api/',
        integration: {
          models: 'Add types to frontend/src/api/models.ts',
          hooks: 'Use with React hooks for type safety',
          components: 'Import in components that use this API'
        },
        securityNotes: [
          'Validate API responses match expected types',
          'Handle error cases with proper typing',
          'Sanitize sensitive data in type definitions'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  private generateInterfaceCode(interfaceName: string, fields: InterfaceField[], extendsInterface?: string, description?: string): string {
    const extendsClause = extendsInterface ? ` extends ${extendsInterface}` : '';
    const descriptionComment = description ? `/**\n * ${description}\n */\n` : '';
    
    const fieldsCode = fields.map(field => {
      const optional = field.optional ? '?' : '';
      const comment = field.description ? ` // ${field.description}` : '';
      return `  ${field.name}${optional}: ${field.type};${comment}`;
    }).join('\n');

    return `${descriptionComment}export interface ${interfaceName}${extendsClause} {
${fieldsCode}
}`;
  }

  private generateTypeDefinition(typeName: string): string {
    // This is a simplified version - in reality, you'd parse the type name and generate appropriate definitions
    return `/**
 * ${typeName} type definition
 * Generated for CoPPA application
 */
export type ${typeName} = {
  // TODO: Define ${typeName} properties
};`;
  }

  private generateApiTypesCode(apiName: string, requestType?: string, responseType?: string, endpoint?: string, method?: string): string {
    const requestInterface = requestType ? `
export interface ${apiName}Request {
  // TODO: Define request properties based on ${requestType}
}` : '';

    const responseInterface = responseType ? `
export interface ${apiName}Response {
  // TODO: Define response properties based on ${responseType}
}` : '';

    const apiFunction = `
/**
 * ${apiName} API function
 * ${method} ${endpoint}
 */
export async function ${apiName.toLowerCase()}Api(${requestType ? `request: ${apiName}Request` : ''}): Promise<${responseType ? `${apiName}Response` : 'Response'}> {
  const response = await fetch('${endpoint || '/api/' + apiName.toLowerCase()}', {
    method: '${method || 'GET'}',
    headers: {
      'Content-Type': 'application/json',
    },${requestType ? `
    body: JSON.stringify(request),` : ''}
  });

  if (!response.ok) {
    throw new Error(\`HTTP error! status: \${response.status}\`);
  }

  return response.json();
}`;

    const hookFunction = `
/**
 * React hook for ${apiName} API
 */
export function use${apiName}() {
  const [data, setData] = useState<${responseType ? `${apiName}Response` : 'any'} | null>(null);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const execute = useCallback(async (${requestType ? `request: ${apiName}Request` : ''}) => {
    setLoading(true);
    setError(null);
    
    try {
      const result = await ${apiName.toLowerCase()}Api(${requestType ? 'request' : ''});
      setData(result);
      return result;
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Unknown error';
      setError(errorMessage);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return { data, loading, error, execute };
}`;

    return `import { useState, useCallback } from 'react';
${requestInterface}${responseInterface}${apiFunction}${hookFunction}`;
  }

  // Additional helper methods for common CoPPA patterns

  generateCoPPAApiTypes(): string {
    return `
// Common CoPPA API Types
export interface CoPPAUser {
  user_id: string;
  user_principal_id: string;
  provider_name: string;
  access_token: string;
  expires_on: string;
}

export interface CoPPAMessage {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  date: string;
  feedback?: Feedback;
  context?: string;
}

export interface CoPPAConversation {
  id: string;
  title: string;
  messages: CoPPAMessage[];
  date: string;
  status?: 'active' | 'completed';
  completedAt?: string;
}

export interface CoPPAApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface CoPPASecurityContext {
  user_id: string;
  permissions: string[];
  force_code?: string;
  clearance_level?: number;
}`;
  }

  generateFluentUITypes(): string {
    return `
// FluentUI Extensions for CoPPA
import { IStackStyles, ITextStyles, IButtonStyles } from '@fluentui/react';

export interface CoPPATheme {
  primary: string;
  secondary: string;
  background: string;
  text: string;
  error: string;
  warning: string;
  success: string;
}

export interface CoPPAComponentStyles {
  container: IStackStyles;
  header: ITextStyles;
  content: IStackStyles;
  actions: IButtonStyles;
}

export interface AccessibleComponentProps {
  ariaLabel?: string;
  ariaDescribedBy?: string;
  role?: string;
  tabIndex?: number;
}`;
  }
}
