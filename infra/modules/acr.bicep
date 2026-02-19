@description('Name of the Azure Container Registry')
param name string

@description('Location for the resource')
param location string

@description('SKU for the Container Registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Tags to apply to the resource')
param tags object = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('The resource ID of the Container Registry')
output id string = containerRegistry.id

@description('The login server URL of the Container Registry')
output loginServer string = containerRegistry.properties.loginServer

@description('The name of the Container Registry')
output name string = containerRegistry.name
