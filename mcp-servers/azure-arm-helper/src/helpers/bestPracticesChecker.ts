export interface BestPracticeCheck {
  category: string;
  rule: string;
  severity: 'error' | 'warning' | 'info';
  message: string;
  suggestion: string;
}

export interface BestPracticeResult {
  score: number; // 0-100
  checks: BestPracticeCheck[];
  summary: {
    errors: number;
    warnings: number;
    info: number;
  };
}

export class BestPracticesChecker {
  async check(args: { templatePath?: string; templateContent?: string }): Promise<BestPracticeResult> {
    try {
      let templateContent: string;
      
      if (args.templatePath) {
        // In a real implementation, you'd use fs.readFileSync
        // For now, we'll assume templateContent is provided
        templateContent = args.templateContent || '{}';
      } else if (args.templateContent) {
        templateContent = args.templateContent;
      } else {
        throw new Error('Either templatePath or templateContent must be provided');
      }

      const template = JSON.parse(templateContent);
      const checks: BestPracticeCheck[] = [];

      // Run all best practice checks
      this.checkNamingConventions(template, checks);
      this.checkSecurityPractices(template, checks);
      this.checkResourceConfiguration(template, checks);
      this.checkParameterization(template, checks);
      this.checkDependencies(template, checks);
      this.checkIdentityBestPractices(template, checks);
      this.checkCostOptimization(template, checks);

      const summary = {
        errors: checks.filter(c => c.severity === 'error').length,
        warnings: checks.filter(c => c.severity === 'warning').length,
        info: checks.filter(c => c.severity === 'info').length
      };

      // Calculate score (100 - (errors * 10 + warnings * 5 + info * 1))
      const score = Math.max(0, 100 - (summary.errors * 10 + summary.warnings * 5 + summary.info * 1));

      return {
        score,
        checks,
        summary
      };
    } catch (error) {
      return {
        score: 0,
        checks: [{
          category: 'Template Parsing',
          rule: 'Valid JSON',
          severity: 'error',
          message: error instanceof Error ? error.message : String(error),
          suggestion: 'Ensure the template is valid JSON format'
        }],
        summary: { errors: 1, warnings: 0, info: 0 }
      };
    }
  }

  private checkNamingConventions(template: any, checks: BestPracticeCheck[]) {
    const resources = template.resources || [];

    for (const resource of resources) {
      // Check for hardcoded names
      if (typeof resource.name === 'string' && !resource.name.startsWith('[')) {
        checks.push({
          category: 'Naming',
          rule: 'No Hardcoded Names',
          severity: 'warning',
          message: `Resource "${resource.name}" uses hardcoded name`,
          suggestion: 'Use variables or parameters for resource names to ensure uniqueness'
        });
      }

      // Check naming patterns
      if (resource.type === 'Microsoft.Storage/storageAccounts') {
        if (typeof resource.name === 'string' && resource.name.length > 24) {
          checks.push({
            category: 'Naming',
            rule: 'Storage Account Name Length',
            severity: 'error',
            message: `Storage account name "${resource.name}" exceeds 24 characters`,
            suggestion: 'Storage account names must be 3-24 characters long'
          });
        }
      }
    }
  }

  private checkSecurityPractices(template: any, checks: BestPracticeCheck[]) {
    const resources = template.resources || [];

    for (const resource of resources) {
      // Check for managed identity usage
      if (resource.type === 'Microsoft.Web/sites' && !resource.identity) {
        checks.push({
          category: 'Security',
          rule: 'Managed Identity',
          severity: 'warning',
          message: `Web App "${resource.name}" should use managed identity`,
          suggestion: 'Add managed identity to eliminate need for stored credentials'
        });
      }

      // Check for public access on storage accounts
      if (resource.type === 'Microsoft.Storage/storageAccounts') {
        if (resource.properties?.allowBlobPublicAccess !== false) {
          checks.push({
            category: 'Security',
            rule: 'Storage Public Access',
            severity: 'warning',
            message: `Storage account "${resource.name}" allows public blob access`,
            suggestion: 'Set allowBlobPublicAccess to false for better security'
          });
        }
      }

      // Check for HTTPS enforcement
      if (resource.type === 'Microsoft.Web/sites') {
        if (resource.properties?.httpsOnly !== true) {
          checks.push({
            category: 'Security',
            rule: 'HTTPS Only',
            severity: 'warning',
            message: `Web App "${resource.name}" should enforce HTTPS`,
            suggestion: 'Set httpsOnly to true in site properties'
          });
        }
      }
    }
  }

  private checkResourceConfiguration(template: any, checks: BestPracticeCheck[]) {
    const resources = template.resources || [];

    for (const resource of resources) {
      // Check for missing location
      if (!resource.location && resource.type !== 'Microsoft.Authorization/roleAssignments') {
        checks.push({
          category: 'Configuration',
          rule: 'Resource Location',
          severity: 'error',
          message: `Resource "${resource.name}" is missing location property`,
          suggestion: 'Add location property, typically using [resourceGroup().location]'
        });
      }

      // Check for missing API version
      if (!resource.apiVersion) {
        checks.push({
          category: 'Configuration',
          rule: 'API Version',
          severity: 'warning',
          message: `Resource "${resource.name}" is missing apiVersion`,
          suggestion: 'Always specify apiVersion for consistent deployments'
        });
      }

      // Check for old API versions (this is a simple heuristic)
      if (resource.apiVersion && typeof resource.apiVersion === 'string') {
        const year = parseInt(resource.apiVersion.split('-')[0]);
        if (year < 2020) {
          checks.push({
            category: 'Configuration',
            rule: 'API Version Currency',
            severity: 'info',
            message: `Resource "${resource.name}" uses old API version ${resource.apiVersion}`,
            suggestion: 'Consider updating to a more recent API version'
          });
        }
      }
    }
  }

  private checkParameterization(template: any, checks: BestPracticeCheck[]) {
    const parameters = template.parameters || {};
    const resources = template.resources || [];

    // Check if commonly parameterized values are hardcoded
    const templateStr = JSON.stringify(template);

    // Check for hardcoded locations
    if (templateStr.includes('"eastus"') || templateStr.includes('"westus"')) {
      checks.push({
        category: 'Parameterization',
        rule: 'Location Parameterization',
        severity: 'info',
        message: 'Template contains hardcoded Azure regions',
        suggestion: 'Consider using [resourceGroup().location] or parameters for locations'
      });
    }

    // Check for unused parameters
    for (const [paramName, param] of Object.entries(parameters)) {
      const paramUsage = `parameters('${paramName}')`;
      if (!templateStr.includes(paramUsage)) {
        checks.push({
          category: 'Parameterization',
          rule: 'Unused Parameters',
          severity: 'info',
          message: `Parameter "${paramName}" is defined but not used`,
          suggestion: 'Remove unused parameters to keep template clean'
        });
      }
    }
  }

  private checkDependencies(template: any, checks: BestPracticeCheck[]) {
    const resources = template.resources || [];
    const resourceNames = new Set(resources.map((r: any) => r.name));

    for (const resource of resources) {
      if (resource.dependsOn) {
        for (const dependency of resource.dependsOn) {
          // Simple check - in real implementation, you'd parse resourceId functions
          if (typeof dependency === 'string' && !dependency.startsWith('[') && !resourceNames.has(dependency)) {
            checks.push({
              category: 'Dependencies',
              rule: 'Valid Dependencies',
              severity: 'error',
              message: `Resource "${resource.name}" depends on non-existent resource "${dependency}"`,
              suggestion: 'Ensure all dependencies reference valid resources'
            });
          }
        }
      }
    }
  }

  private checkIdentityBestPractices(template: any, checks: BestPracticeCheck[]) {
    const resources = template.resources || [];
    const templateStr = JSON.stringify(template);

    // Check for proper identity reference patterns
    if (templateStr.includes('.identity.principalId')) {
      // Check if using 'full' parameter
      const referencePattern = /reference\([^)]+\)\.identity\.principalId/g;
      const matches = templateStr.match(referencePattern);
      
      if (matches) {
        for (const match of matches) {
          if (!match.includes("'full'") && !match.includes('"full"')) {
            checks.push({
              category: 'Identity',
              rule: 'Identity Reference Pattern',
              severity: 'error',
              message: 'Identity reference missing "full" parameter',
              suggestion: 'Add "full" parameter to reference() when accessing identity properties: reference(..., "full").identity.principalId'
            });
          }
        }
      }
    }

    // Check for role assignments without proper GUID generation
    for (const resource of resources) {
      if (resource.type === 'Microsoft.Authorization/roleAssignments') {
        if (typeof resource.name === 'string' && !resource.name.includes('guid(')) {
          checks.push({
            category: 'Identity',
            rule: 'Role Assignment Naming',
            severity: 'warning',
            message: `Role assignment "${resource.name}" should use guid() for uniqueness`,
            suggestion: 'Use guid() function to generate unique names for role assignments'
          });
        }
      }
    }
  }

  private checkCostOptimization(template: any, checks: BestPracticeCheck[]) {
    const resources = template.resources || [];

    for (const resource of resources) {
      // Check for premium SKUs without justification
      if (resource.properties?.sku) {
        const sku = resource.properties.sku;
        if (typeof sku.name === 'string' && sku.name.toLowerCase().includes('premium')) {
          checks.push({
            category: 'Cost',
            rule: 'SKU Selection',
            severity: 'info',
            message: `Resource "${resource.name}" uses premium SKU`,
            suggestion: 'Ensure premium SKU is necessary for your requirements'
          });
        }
      }

      // Check for auto-scaling configuration
      if (resource.type === 'Microsoft.Web/serverfarms') {
        if (!resource.properties?.reserved && !resource.properties?.targetWorkerCount) {
          checks.push({
            category: 'Cost',
            rule: 'Auto-scaling',
            severity: 'info',
            message: `App Service Plan "${resource.name}" might benefit from auto-scaling`,
            suggestion: 'Consider configuring auto-scaling to optimize costs'
          });
        }
      }
    }
  }
}
