// Managed Identity Module for Deployment Scripts
// Creates a user-assigned managed identity with required permissions for Azure AD App Registration

@description('Name of the managed identity')
param managedIdentityName string

@description('Resource group location')
param location string = resourceGroup().location

@description('Tags to apply to resources')
param tags object = {}

// Create user-assigned managed identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: tags
}

// Grant Cloud Application Administrator role to managed identity for creating app registrations
// This allows the deployment script to create Azure AD App Registrations
resource graphPermissionAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(managedIdentity.id, 'CloudApplicationAdministrator', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1138cb37-bd11-4084-a2b7-9f71582aeddb') // Cloud Application Administrator
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Output managed identity details
output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedIdentityClientId string = managedIdentity.properties.clientId
