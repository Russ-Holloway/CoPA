export interface IdentityReferencePattern {
  resourceType: string;
  identityType: 'SystemAssigned' | 'UserAssigned';
  referencePattern: string;
  example: string;
  commonIssues: string[];
}

export interface RoleAssignmentPattern {
  sourceResourceType: string;
  targetResourceType: string;
  roleDefinition: string;
  template: string;
  explanation: string;
}

export class IdentityReferenceHelper {
  private patterns: IdentityReferencePattern[] = [
    {
      resourceType: 'Microsoft.Web/sites',
      identityType: 'SystemAssigned',
      referencePattern: "reference(resourceId('Microsoft.Web/sites', variables('WebsiteName')), '2022-09-01', 'full').identity.principalId",
      example: "reference(resourceId('Microsoft.Web/sites', variables('WebAppName')), '2022-09-01', 'full').identity.principalId",
      commonIssues: [
        'Missing "full" parameter in reference function',
        'Incorrect API version',
        'Wrong resource reference syntax'
      ]
    },
    {
      resourceType: 'Microsoft.Web/sites',
      identityType: 'UserAssigned',
      referencePattern: "reference(resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', variables('IdentityName')), '2018-11-30').principalId",
      example: "reference(resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', variables('UserIdentityName')), '2018-11-30').principalId",
      commonIssues: [
        'Referencing wrong identity resource',
        'Incorrect API version for user-assigned identity'
      ]
    },
    {
      resourceType: 'Microsoft.Compute/virtualMachines',
      identityType: 'SystemAssigned',
      referencePattern: "reference(resourceId('Microsoft.Compute/virtualMachines', variables('VMName')), '2021-03-01', 'full').identity.principalId",
      example: "reference(resourceId('Microsoft.Compute/virtualMachines', variables('VirtualMachineName')), '2021-03-01', 'full').identity.principalId",
      commonIssues: [
        'Missing "full" parameter in reference function'
      ]
    }
  ];

  private roleAssignmentPatterns: RoleAssignmentPattern[] = [
    {
      sourceResourceType: 'Microsoft.Web/sites',
      targetResourceType: 'Microsoft.Storage/storageAccounts',
      roleDefinition: 'Storage Blob Data Contributor',
      template: `{
  "type": "Microsoft.Authorization/roleAssignments",
  "apiVersion": "2022-04-01",
  "scope": "[resourceId('Microsoft.Storage/storageAccounts', variables('StorageAccountName'))]",
  "name": "[guid(resourceId('Microsoft.Storage/storageAccounts', variables('StorageAccountName')), resourceId('Microsoft.Web/sites', variables('WebAppName')), 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')]",
  "dependsOn": [
    "[resourceId('Microsoft.Storage/storageAccounts', variables('StorageAccountName'))]",
    "[resourceId('Microsoft.Web/sites', variables('WebAppName'))]"
  ],
  "properties": {
    "roleDefinitionId": "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe')]",
    "principalId": "[reference(resourceId('Microsoft.Web/sites', variables('WebAppName')), '2022-09-01', 'full').identity.principalId]",
    "principalType": "ServicePrincipal"
  }
}`,
      explanation: 'Assigns Storage Blob Data Contributor role to a Web App\'s system-assigned managed identity'
    },
    {
      sourceResourceType: 'Microsoft.Web/sites',
      targetResourceType: 'Microsoft.DocumentDB/databaseAccounts',
      roleDefinition: 'Cosmos DB Built-in Data Contributor',
      template: `{
  "type": "Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments",
  "apiVersion": "2021-04-15",
  "name": "[format('{0}/{1}', variables('CosmosDBAccountName'), guid(resourceId('Microsoft.DocumentDB/databaseAccounts', variables('CosmosDBAccountName')), resourceId('Microsoft.Web/sites', variables('WebAppName'))))]",
  "dependsOn": [
    "[resourceId('Microsoft.DocumentDB/databaseAccounts', variables('CosmosDBAccountName'))]",
    "[resourceId('Microsoft.Web/sites', variables('WebAppName'))]"
  ],
  "properties": {
    "roleDefinitionId": "[resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', variables('CosmosDBAccountName'), '00000000-0000-0000-0000-000000000002')]",
    "principalId": "[reference(resourceId('Microsoft.Web/sites', variables('WebAppName')), '2022-09-01', 'full').identity.principalId]",
    "scope": "[resourceId('Microsoft.DocumentDB/databaseAccounts', variables('CosmosDBAccountName'))]"
  }
}`,
      explanation: 'Assigns Cosmos DB Built-in Data Contributor role to a Web App\'s system-assigned managed identity'
    }
  ];

  async generateCorrectReference(args: {
    resourceType: string;
    identityType: 'SystemAssigned' | 'UserAssigned';
    targetResource?: string;
  }): Promise<string> {
    const pattern = this.patterns.find(p => 
      p.resourceType === args.resourceType && p.identityType === args.identityType
    );

    if (!pattern) {
      return `No pattern found for ${args.resourceType} with ${args.identityType} identity. 
      
Common patterns:
${this.patterns.map(p => `- ${p.resourceType} (${p.identityType}): ${p.referencePattern}`).join('\n')}`;
    }

    return `Correct reference pattern for ${args.resourceType} with ${args.identityType} identity:

Pattern: ${pattern.referencePattern}
Example: ${pattern.example}

Common Issues to Avoid:
${pattern.commonIssues.map(issue => `- ${issue}`).join('\n')}

Key Points:
1. Always use 'full' parameter when accessing identity properties
2. Use the correct API version for your resource type
3. Ensure proper dependsOn relationships
4. Use resourceId() function for proper resource references`;
  }

  async suggestRoleAssignmentPattern(args: {
    sourceResourceType: string;
    targetResourceType: string;
    roleDefinition: string;
  }): Promise<string> {
    const pattern = this.roleAssignmentPatterns.find(p =>
      p.sourceResourceType === args.sourceResourceType &&
      p.targetResourceType === args.targetResourceType &&
      (p.roleDefinition === args.roleDefinition || p.roleDefinition.toLowerCase().includes(args.roleDefinition.toLowerCase()))
    );

    if (pattern) {
      return `Found matching pattern:

${pattern.explanation}

Template:
${pattern.template}

Key Points:
1. Use proper GUID generation for role assignment names to ensure uniqueness
2. Include both source and target resources in dependsOn
3. Use 'full' parameter when referencing managed identity
4. Set correct principalType (ServicePrincipal for managed identities)`;
    }

    // Generic pattern based on resource types
    const isCosmosDB = args.targetResourceType === 'Microsoft.DocumentDB/databaseAccounts';
    const isStorage = args.targetResourceType === 'Microsoft.Storage/storageAccounts';

    if (isCosmosDB) {
      return `For Cosmos DB role assignments, use Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments:

{
  "type": "Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments",
  "apiVersion": "2021-04-15",
  "name": "[format('{0}/{1}', variables('CosmosDBAccountName'), guid(resourceGroup().id, variables('WebAppName'), '${args.roleDefinition}'))]",
  "dependsOn": [
    "[resourceId('Microsoft.DocumentDB/databaseAccounts', variables('CosmosDBAccountName'))]",
    "[resourceId('${args.sourceResourceType}', variables('SourceResourceName'))]"
  ],
  "properties": {
    "roleDefinitionId": "[resourceId('Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions', variables('CosmosDBAccountName'), 'ROLE_DEFINITION_ID')]",
    "principalId": "[reference(resourceId('${args.sourceResourceType}', variables('SourceResourceName')), 'API_VERSION', 'full').identity.principalId]",
    "scope": "[resourceId('Microsoft.DocumentDB/databaseAccounts', variables('CosmosDBAccountName'))]"
  }
}

Common Cosmos DB Role Definition IDs:
- Cosmos DB Built-in Data Reader: 00000000-0000-0000-0000-000000000001
- Cosmos DB Built-in Data Contributor: 00000000-0000-0000-0000-000000000002`;
    }

    if (isStorage) {
      return `For Storage Account role assignments, use Microsoft.Authorization/roleAssignments:

{
  "type": "Microsoft.Authorization/roleAssignments",
  "apiVersion": "2022-04-01",
  "scope": "[resourceId('Microsoft.Storage/storageAccounts', variables('StorageAccountName'))]",
  "name": "[guid(resourceId('Microsoft.Storage/storageAccounts', variables('StorageAccountName')), resourceId('${args.sourceResourceType}', variables('SourceResourceName')), 'ROLE_DEFINITION_ID')]",
  "dependsOn": [
    "[resourceId('Microsoft.Storage/storageAccounts', variables('StorageAccountName'))]",
    "[resourceId('${args.sourceResourceType}', variables('SourceResourceName'))]"
  ],
  "properties": {
    "roleDefinitionId": "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/ROLE_DEFINITION_ID')]",
    "principalId": "[reference(resourceId('${args.sourceResourceType}', variables('SourceResourceName')), 'API_VERSION', 'full').identity.principalId]",
    "principalType": "ServicePrincipal"
  }
}

Common Storage Role Definition IDs:
- Storage Blob Data Reader: 2a2b9908-6ea1-4ae2-8e65-a410df84e7d1
- Storage Blob Data Contributor: ba92f5b4-2d11-453d-a403-e96b0029c9fe
- Storage Blob Data Owner: b7e6dc6d-f1e8-4753-8033-0f276bb0955b`;
    }

    return `Generic role assignment pattern for ${args.sourceResourceType} -> ${args.targetResourceType}:

{
  "type": "Microsoft.Authorization/roleAssignments",
  "apiVersion": "2022-04-01",
  "scope": "[resourceId('${args.targetResourceType}', variables('TargetResourceName'))]",
  "name": "[guid(resourceId('${args.targetResourceType}', variables('TargetResourceName')), resourceId('${args.sourceResourceType}', variables('SourceResourceName')), 'ROLE_DEFINITION_ID')]",
  "dependsOn": [
    "[resourceId('${args.targetResourceType}', variables('TargetResourceName'))]",
    "[resourceId('${args.sourceResourceType}', variables('SourceResourceName'))]"
  ],
  "properties": {
    "roleDefinitionId": "[concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/ROLE_DEFINITION_ID')]",
    "principalId": "[reference(resourceId('${args.sourceResourceType}', variables('SourceResourceName')), 'API_VERSION', 'full').identity.principalId]",
    "principalType": "ServicePrincipal"
  }
}

Replace:
- ROLE_DEFINITION_ID with the appropriate Azure role definition ID
- API_VERSION with the correct API version for your source resource
- Variable names with your actual variable names`;
  }
}
