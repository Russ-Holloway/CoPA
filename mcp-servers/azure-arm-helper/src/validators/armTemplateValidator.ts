import * as fs from 'fs';
import * as path from 'path';

export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
  suggestions: string[];
}

export interface ValidationError {
  line?: number;
  column?: number;
  message: string;
  severity: 'error' | 'warning';
  code?: string;
}

export interface ValidationWarning {
  line?: number;
  column?: number;
  message: string;
  code?: string;
}

export interface DependencyAnalysis {
  resources: ResourceInfo[];
  dependencyGraph: DependencyGraph;
  circularDependencies: string[];
  missingDependencies: string[];
}

export interface ResourceInfo {
  name: string;
  type: string;
  dependsOn: string[];
  dependedBy: string[];
}

export interface DependencyGraph {
  [resourceName: string]: string[];
}

export class ARMTemplateValidator {
  async validate(args: { templatePath?: string; templateContent?: string }): Promise<ValidationResult> {
    try {
      let templateContent: string;
      
      if (args.templatePath) {
        templateContent = fs.readFileSync(args.templatePath, 'utf8');
      } else if (args.templateContent) {
        templateContent = args.templateContent;
      } else {
        throw new Error('Either templatePath or templateContent must be provided');
      }

      const template = JSON.parse(templateContent);
      const result: ValidationResult = {
        isValid: true,
        errors: [],
        warnings: [],
        suggestions: []
      };

      // Basic schema validation
      this.validateSchema(template, result);
      
      // Resource validation
      this.validateResources(template, result);
      
      // Parameter validation
      this.validateParameters(template, result);
      
      // Variable validation
      this.validateVariables(template, result);

      // Identity reference validation (our specific issue)
      this.validateIdentityReferences(template, result);

      result.isValid = result.errors.length === 0;
      return result;
    } catch (error) {
      return {
        isValid: false,
        errors: [{
          message: error instanceof Error ? error.message : String(error),
          severity: 'error'
        }],
        warnings: [],
        suggestions: []
      };
    }
  }

  async analyzeDependencies(args: { templatePath?: string; templateContent?: string }): Promise<DependencyAnalysis> {
    try {
      let templateContent: string;
      
      if (args.templatePath) {
        templateContent = fs.readFileSync(args.templatePath, 'utf8');
      } else if (args.templateContent) {
        templateContent = args.templateContent;
      } else {
        throw new Error('Either templatePath or templateContent must be provided');
      }

      const template = JSON.parse(templateContent);
      const resources = template.resources || [];
      
      const resourceInfo: ResourceInfo[] = [];
      const dependencyGraph: DependencyGraph = {};

      // Build resource info and dependency graph
      for (const resource of resources) {
        const resourceName = resource.name;
        const dependsOn = resource.dependsOn || [];
        
        resourceInfo.push({
          name: resourceName,
          type: resource.type,
          dependsOn,
          dependedBy: []
        });

        dependencyGraph[resourceName] = dependsOn;
      }

      // Fill in dependedBy relationships
      for (const resource of resourceInfo) {
        for (const dependency of resource.dependsOn) {
          const dependedResource = resourceInfo.find(r => r.name === dependency);
          if (dependedResource) {
            dependedResource.dependedBy.push(resource.name);
          }
        }
      }

      const circularDependencies = this.detectCircularDependencies(dependencyGraph);
      const missingDependencies = this.detectMissingDependencies(resourceInfo);

      return {
        resources: resourceInfo,
        dependencyGraph,
        circularDependencies,
        missingDependencies
      };
    } catch (error) {
      throw new Error(`Dependency analysis failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private validateSchema(template: any, result: ValidationResult) {
    if (!template.$schema) {
      result.warnings.push({
        message: 'Template is missing $schema property',
        code: 'MISSING_SCHEMA'
      });
    }

    if (!template.contentVersion) {
      result.warnings.push({
        message: 'Template is missing contentVersion property',
        code: 'MISSING_CONTENT_VERSION'
      });
    }

    if (!template.resources || !Array.isArray(template.resources)) {
      result.errors.push({
        message: 'Template must have a resources array',
        severity: 'error',
        code: 'MISSING_RESOURCES'
      });
    }
  }

  private validateResources(template: any, result: ValidationResult) {
    const resources = template.resources || [];
    
    for (let i = 0; i < resources.length; i++) {
      const resource = resources[i];
      
      if (!resource.type) {
        result.errors.push({
          message: `Resource at index ${i} is missing type property`,
          severity: 'error',
          code: 'MISSING_RESOURCE_TYPE'
        });
      }

      if (!resource.name) {
        result.errors.push({
          message: `Resource at index ${i} is missing name property`,
          severity: 'error',
          code: 'MISSING_RESOURCE_NAME'
        });
      }

      if (!resource.apiVersion) {
        result.warnings.push({
          message: `Resource ${resource.name} is missing apiVersion property`,
          code: 'MISSING_API_VERSION'
        });
      }

      // Check for duplicate resource names
      const duplicates = resources.filter((r: any, idx: number) => 
        idx !== i && r.name === resource.name
      );
      if (duplicates.length > 0) {
        result.errors.push({
          message: `Duplicate resource name: ${resource.name}`,
          severity: 'error',
          code: 'DUPLICATE_RESOURCE_NAME'
        });
      }
    }
  }

  private validateParameters(template: any, result: ValidationResult) {
    const parameters = template.parameters || {};
    
    for (const [paramName, param] of Object.entries(parameters)) {
      const paramDef = param as any;
      if (!paramDef.type) {
        result.warnings.push({
          message: `Parameter ${paramName} is missing type property`,
          code: 'MISSING_PARAMETER_TYPE'
        });
      }
    }
  }

  private validateVariables(template: any, result: ValidationResult) {
    // Variables validation can be added here
    // For now, just check if variables exist but are empty
    if (template.variables && Object.keys(template.variables).length === 0) {
      result.suggestions.push('Consider removing empty variables section');
    }
  }

  private validateIdentityReferences(template: any, result: ValidationResult) {
    const resources = template.resources || [];
    
    for (const resource of resources) {
      // Check for managed identity reference patterns
      if (resource.properties) {
        const props = JSON.stringify(resource.properties);
        
        // Look for common identity reference issues
        if (props.includes('reference(') && props.includes('.identity.principalId')) {
          // Check if using the correct reference syntax
          const referencePattern = /reference\([^)]+\)\.identity\.principalId/g;
          const matches = props.match(referencePattern);
          
          if (matches) {
            for (const match of matches) {
              if (!match.includes("'full'") && !match.includes('"full"')) {
                result.warnings.push({
                  message: `Identity reference may need 'full' parameter: ${match}`,
                  code: 'IDENTITY_REFERENCE_MISSING_FULL'
                });
                result.suggestions.push("Add 'full' parameter to reference() when accessing identity properties: reference(resourceId(...), 'apiVersion', 'full').identity.principalId");
              }
            }
          }
        }
      }
    }
  }

  private detectCircularDependencies(dependencyGraph: DependencyGraph): string[] {
    const circular: string[] = [];
    const visited = new Set<string>();
    const recursionStack = new Set<string>();

    const dfs = (resource: string): boolean => {
      visited.add(resource);
      recursionStack.add(resource);

      const dependencies = dependencyGraph[resource] || [];
      for (const dependency of dependencies) {
        if (!visited.has(dependency)) {
          if (dfs(dependency)) {
            return true;
          }
        } else if (recursionStack.has(dependency)) {
          circular.push(`${resource} -> ${dependency}`);
          return true;
        }
      }

      recursionStack.delete(resource);
      return false;
    };

    for (const resource of Object.keys(dependencyGraph)) {
      if (!visited.has(resource)) {
        dfs(resource);
      }
    }

    return circular;
  }

  private detectMissingDependencies(resources: ResourceInfo[]): string[] {
    const missing: string[] = [];
    const resourceNames = new Set(resources.map(r => r.name));

    for (const resource of resources) {
      for (const dependency of resource.dependsOn) {
        if (!resourceNames.has(dependency)) {
          missing.push(`${resource.name} depends on missing resource: ${dependency}`);
        }
      }
    }

    return missing;
  }
}
