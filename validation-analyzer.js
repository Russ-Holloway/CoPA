// validation-analyzer.js
const fs = require('fs');
const path = require('path');

function validateArmTemplate(template) {
    const issues = [];
    
    // Check for common issues
    
    // 1. Check for missing required properties
    if (!template.resources || !Array.isArray(template.resources)) {
        issues.push('Template is missing resources array');
    }
    
    // 2. Check API versions
    const apiVersionIssues = [];
    if (template.resources) {
        for (const resource of template.resources) {
            // Known older API versions that should work fine
            const knownValidApiVersions = {
                'Microsoft.CognitiveServices/accounts': ['2021-10-01', '2021-04-30', '2017-04-18'],
                'Microsoft.CognitiveServices/accounts/deployments': ['2021-10-01', '2021-04-30'],
                'Microsoft.DocumentDB/databaseAccounts': ['2021-01-15', '2021-04-15', '2021-06-15'],
                'Microsoft.DocumentDB/databaseAccounts/sqlDatabases': ['2021-01-15', '2021-04-15'],
                'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers': ['2021-01-15', '2021-04-15'],
                'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments': ['2021-04-15']
            };
            
            if (resource.type && resource.apiVersion) {
                const validVersions = knownValidApiVersions[resource.type];
                if (validVersions && !validVersions.includes(resource.apiVersion)) {
                    apiVersionIssues.push(`Resource ${resource.type} uses apiVersion ${resource.apiVersion}, but valid versions are: ${validVersions.join(', ')}`);
                }
            }
        }
    }
    
    if (apiVersionIssues.length > 0) {
        issues.push('API Version issues found:', ...apiVersionIssues);
    }
    
    // 3. Check for reference issues
    if (template.resources) {
        const resourceNames = template.resources.map(r => r.name);
        const dependsOnIssues = [];
        
        for (const resource of template.resources) {
            if (resource.dependsOn) {
                for (const dependency of resource.dependsOn) {
                    // Simple check - in practice this would be more complex to validate resourceId() functions
                    if (typeof dependency === 'string' && !dependency.includes('resourceId(')) {
                        if (!resourceNames.includes(dependency)) {
                            dependsOnIssues.push(`Resource ${resource.name} depends on ${dependency}, which may not exist in the template`);
                        }
                    }
                }
            }
        }
        
        if (dependsOnIssues.length > 0) {
            issues.push('Dependency issues found:', ...dependsOnIssues);
        }
    }
    
    // 4. Check for JSON comments, which are not supported in ARM templates
    const jsonStr = JSON.stringify(template);
    if (jsonStr.includes('//')) {
        issues.push('JSON comments (// style) detected, which are not supported in ARM templates');
    }
    
    return issues;
}

try {
    // Path to the JSON file
    const filePath = path.join(__dirname, 'infrastructure', 'deployment.json');
    
    // Read the file
    const jsonContent = fs.readFileSync(filePath, 'utf8');
    
    // Try to parse it
    const template = JSON.parse(jsonContent);
    
    console.log('✅ JSON syntax is valid');
    
    // Validate ARM template structure
    const issues = validateArmTemplate(template);
    
    if (issues.length === 0) {
        console.log('✅ No obvious ARM template issues detected');
    } else {
        console.log('⚠️ Potential issues found:');
        issues.forEach(issue => console.log(`   - ${issue}`));
    }
    
} catch (error) {
    console.error('❌ JSON validation failed:', error.message);
    process.exit(1);
}
