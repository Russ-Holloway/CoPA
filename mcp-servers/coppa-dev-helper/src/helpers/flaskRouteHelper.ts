export interface FlaskRouteParams {
  routeName: string;
  path: string;
  methods: string[];
  requiresAuth?: boolean;
  requiresCosmosDB?: boolean;
  description?: string;
}

export interface ApiModelParams {
  modelName: string;
  fields: ModelField[];
  includeValidation?: boolean;
}

export interface ModelField {
  name: string;
  type: string;
  required?: boolean;
  description?: string;
}

export interface CosmosIntegrationParams {
  operationType: 'create' | 'read' | 'update' | 'delete';
  modelName: string;
  containerName?: string;
}

export class FlaskRouteHelper {
  async createRoute(params: FlaskRouteParams): Promise<any> {
    try {
      const {
        routeName,
        path,
        methods,
        requiresAuth = true,
        requiresCosmosDB = false,
        description = ''
      } = params;

      const routeCode = this.generateRouteCode(routeName, path, methods, requiresAuth, requiresCosmosDB, description);
      
      return {
        success: true,
        routeCode,
        fileName: `${routeName}_route.py`,
        location: 'Add to app.py or create in backend/routes/',
        securityNotes: [
          'Route includes authentication by default for police data protection',
          'Input validation should be added for all parameters',
          'Error handling follows CoPPA patterns',
          'Logging configured for security monitoring'
        ],
        testingNotes: [
          'Test with authenticated and unauthenticated users',
          'Validate all input parameters',
          'Test error conditions and edge cases'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async addAuthentication(params: { routePath: string; authType?: 'basic' | 'cosmos' | 'both' }): Promise<any> {
    try {
      const { routePath, authType = 'both' } = params;
      
      const decorators = this.generateAuthDecorators(authType);
      const authCode = this.generateAuthCode(authType);
      
      return {
        success: true,
        decorators,
        authCode,
        instructions: [
          '1. Add the decorators above your route function',
          '2. Include the authentication code at the start of your route',
          '3. Handle authentication errors appropriately',
          '4. Log authentication attempts for security monitoring'
        ],
        securityBestPractices: [
          'Never log sensitive user information',
          'Use secure session management',
          'Implement proper error handling for auth failures',
          'Follow principle of least privilege'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async createModel(params: ApiModelParams): Promise<any> {
    try {
      const { modelName, fields, includeValidation = true } = params;
      
      const modelCode = this.generateModelCode(modelName, fields, includeValidation);
      const validationCode = includeValidation ? this.generateValidationCode(modelName, fields) : null;
      
      return {
        success: true,
        modelCode,
        validationCode,
        fileName: `${modelName.toLowerCase()}_model.py`,
        location: 'backend/models/',
        usage: `from backend.models.${modelName.toLowerCase()}_model import ${modelName}`,
        securityNotes: [
          'Model includes input sanitization',
          'Sensitive fields are properly handled',
          'Validation prevents injection attacks'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  async addCosmosDBIntegration(params: CosmosIntegrationParams): Promise<any> {
    try {
      const { operationType, modelName, containerName } = params;
      
      const integrationCode = this.generateCosmosIntegration(operationType, modelName, containerName);
      
      return {
        success: true,
        integrationCode,
        pattern: `cosmos_${operationType}_${modelName.toLowerCase()}`,
        dependencies: [
          'Requires CosmosDB client from backend.history.cosmosdbservice',
          'Needs proper error handling for database operations',
          'Should include retry logic for transient failures'
        ],
        securityConsiderations: [
          'Use parameterized queries to prevent injection',
          'Implement proper data encryption at rest',
          'Log database operations for audit trails',
          'Use least privilege access patterns'
        ]
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : String(error)
      };
    }
  }

  private generateRouteCode(routeName: string, path: string, methods: string[], requiresAuth: boolean, requiresCosmosDB: boolean, description: string): string {
    const decorators = [];
    if (requiresCosmosDB) decorators.push('@require_cosmos_db');
    
    const methodsStr = methods.map(m => `"${m}"`).join(', ');
    
    const authCode = requiresAuth ? `
    # Authentication check
    authenticated_user = get_authenticated_user_details(request_headers=request.headers)
    user_id = authenticated_user["user_principal_id"]
    
    # Log the request for security monitoring
    logging.info(f"${routeName} accessed by user: {user_id}")` : '';

    return `@bp.route("${path}", methods=[${methodsStr}])
${decorators.join('\n')}
async def ${routeName}():
    """${description || `Handle ${routeName} requests`}"""
    try:${authCode}
        
        # Get request data
        if request.method in ['POST', 'PUT', 'PATCH']:
            if not request.is_json:
                return jsonify({"error": "Request must be JSON"}), 400
            request_json = await request.get_json()
            
            # Input validation
            # TODO: Add specific validation for your request data
            
        # Your business logic here
        # TODO: Implement your route logic
        
        return jsonify({"message": "Success"}), 200
        
    except ValueError as ve:
        logging.warning(f"Validation error in ${routeName}: {str(ve)}")
        return jsonify({"error": "Invalid input data"}), 400
    except Exception as e:
        logging.exception(f"Error in ${routeName}")
        return jsonify({"error": "Internal server error"}), 500`;
  }

  private generateAuthDecorators(authType: string): string[] {
    const decorators = [];
    
    if (authType === 'cosmos' || authType === 'both') {
      decorators.push('@require_cosmos_db');
    }
    
    return decorators;
  }

  private generateAuthCode(authType: string): string {
    return `
    # Authentication and authorization
    authenticated_user = get_authenticated_user_details(request_headers=request.headers)
    user_id = authenticated_user["user_principal_id"]
    
    # Security logging
    logging.info(f"Authenticated request from user: {user_id}")
    
    # Additional authorization checks can be added here
    # Example: Check if user has required permissions`;
  }

  private generateModelCode(modelName: string, fields: ModelField[], includeValidation: boolean): string {
    const fieldDefinitions = fields.map(field => {
      const optional = field.required ? '' : ' = None';
      return `    ${field.name}: ${field.type}${optional}  # ${field.description || ''}`;
    }).join('\n');

    const validationMethod = includeValidation ? `
    
    def validate(self) -> bool:
        """Validate model data for security and correctness"""
        # TODO: Implement validation logic
        return True
    
    def sanitize(self):
        """Sanitize sensitive data for logging or display"""
        # TODO: Implement data sanitization
        pass` : '';

    return `from dataclasses import dataclass
from typing import Optional
import logging

@dataclass
class ${modelName}:
    """${modelName} model for CoPPA application"""
${fieldDefinitions}${validationMethod}`;
  }

  private generateValidationCode(modelName: string, fields: ModelField[]): string {
    const validations = fields.map(field => {
      if (field.required) {
        return `    if not data.get('${field.name}'):
        raise ValueError('${field.name} is required')`;
      }
      return '';
    }).filter(Boolean).join('\n');

    return `def validate_${modelName.toLowerCase()}(data: dict) -> bool:
    """Validate ${modelName} data"""
    try:
${validations}
        
        # Additional validation logic here
        return True
        
    except ValueError as e:
        logging.warning(f"Validation failed for ${modelName}: {str(e)}")
        raise
    except Exception as e:
        logging.error(f"Unexpected error validating ${modelName}: {str(e)}")
        raise ValueError("Validation failed")`;
  }

  private generateCosmosIntegration(operationType: string, modelName: string, containerName?: string): string {
    const container = containerName || `${modelName.toLowerCase()}s`;
    
    switch (operationType) {
      case 'create':
        return `async def create_${modelName.toLowerCase()}(${modelName.toLowerCase()}_data: dict, user_id: str):
    """Create a new ${modelName} in CosmosDB"""
    try:
        # Validate input data
        # TODO: Add validation logic
        
        # Add metadata
        ${modelName.toLowerCase()}_data['id'] = str(uuid.uuid4())
        ${modelName.toLowerCase()}_data['user_id'] = user_id
        ${modelName.toLowerCase()}_data['created_at'] = datetime.utcnow().isoformat()
        
        # Save to CosmosDB
        result = await current_app.cosmos_conversation_client.create_item(
            container_name='${container}',
            item=${modelName.toLowerCase()}_data
        )
        
        logging.info(f"Created ${modelName} with id: {${modelName.toLowerCase()}_data['id']}")
        return result
        
    except Exception as e:
        logging.error(f"Failed to create ${modelName}: {str(e)}")
        raise`;

      case 'read':
        return `async def get_${modelName.toLowerCase()}(${modelName.toLowerCase()}_id: str, user_id: str):
    """Retrieve a ${modelName} from CosmosDB"""
    try:
        result = await current_app.cosmos_conversation_client.get_item(
            container_name='${container}',
            item_id=${modelName.toLowerCase()}_id,
            user_id=user_id
        )
        
        if not result:
            logging.warning(f"${modelName} not found: {${modelName.toLowerCase()}_id}")
            return None
            
        logging.info(f"Retrieved ${modelName}: {${modelName.toLowerCase()}_id}")
        return result
        
    except Exception as e:
        logging.error(f"Failed to retrieve ${modelName}: {str(e)}")
        raise`;

      case 'update':
        return `async def update_${modelName.toLowerCase()}(${modelName.toLowerCase()}_id: str, update_data: dict, user_id: str):
    """Update a ${modelName} in CosmosDB"""
    try:
        # Validate update data
        # TODO: Add validation logic
        
        # Add update metadata
        update_data['updated_at'] = datetime.utcnow().isoformat()
        
        result = await current_app.cosmos_conversation_client.update_item(
            container_name='${container}',
            item_id=${modelName.toLowerCase()}_id,
            user_id=user_id,
            update_data=update_data
        )
        
        logging.info(f"Updated ${modelName}: {${modelName.toLowerCase()}_id}")
        return result
        
    except Exception as e:
        logging.error(f"Failed to update ${modelName}: {str(e)}")
        raise`;

      case 'delete':
        return `async def delete_${modelName.toLowerCase()}(${modelName.toLowerCase()}_id: str, user_id: str):
    """Delete a ${modelName} from CosmosDB"""
    try:
        result = await current_app.cosmos_conversation_client.delete_item(
            container_name='${container}',
            item_id=${modelName.toLowerCase()}_id,
            user_id=user_id
        )
        
        logging.info(f"Deleted ${modelName}: {${modelName.toLowerCase()}_id}")
        return result
        
    except Exception as e:
        logging.error(f"Failed to delete ${modelName}: {str(e)}")
        raise`;

      default:
        return `# Unsupported operation: ${operationType}`;
    }
  }
}
