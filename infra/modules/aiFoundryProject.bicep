@description('Name of the AI Foundry Project')
param name string

@description('Location for the resource')
param location string

@description('Resource ID of the parent AI Foundry Hub')
param aiFoundryHubId string

@description('Tags to apply to the resource')
param tags object = {}

resource aiFoundryProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: 'ZavaStorefront Dev Project'
    hubResourceId: aiFoundryHubId
  }
}

@description('The resource ID of the AI Foundry Project')
output id string = aiFoundryProject.id

@description('The name of the AI Foundry Project')
output name string = aiFoundryProject.name
