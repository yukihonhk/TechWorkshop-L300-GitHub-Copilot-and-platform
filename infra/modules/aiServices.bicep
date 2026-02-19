@description('Name of the Azure AI Services account')
param name string

@description('Location for the resource')
param location string

@description('SKU for the AI Services account')
param sku string = 'S0'

@description('Tags to apply to the resource')
param tags object = {}

resource aiServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// GPT-4o model deployment (GlobalStandard SKU available in westus3)
resource gpt4Deployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServices
  name: 'gpt-4o'
  sku: {
    name: 'GlobalStandard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
  }
}

// Phi-4 model deployment
resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: aiServices
  name: 'Phi-4'
  dependsOn: [gpt4Deployment]
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-4'
      version: '2'
    }
  }
}

@description('The resource ID of the AI Services account')
output id string = aiServices.id

@description('The endpoint of the AI Services account')
output endpoint string = aiServices.properties.endpoint

@description('The name of the AI Services account')
output name string = aiServices.name
