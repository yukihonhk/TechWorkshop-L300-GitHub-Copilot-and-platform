@description('Name of the AI Foundry Hub (Azure ML Workspace with kind=Hub)')
@minLength(3)
param name string

@description('Location for the resource')
param location string

@description('Resource ID of the AI Services account to connect')
param aiServicesId string

@description('Name of the AI Services account')
param aiServicesName string

@description('Name of the storage account for the hub')
param storageAccountName string

@description('Name of the Key Vault for the hub')
@minLength(3)
param keyVaultName string

@description('Tags to apply to the resource')
param tags object = {}

// Storage account required by AI Foundry Hub
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

// Key Vault required by AI Foundry Hub
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
  }
}

resource aiFoundryHub 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: 'AI Foundry Hub - ${name}'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
  }
}

// Connection to AI Services
resource aiServicesConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-10-01' = {
  parent: aiFoundryHub
  name: '${aiServicesName}-connection'
  properties: {
    category: 'AIServices'
    authType: 'AAD'
    isSharedToAll: true
    target: aiServicesId
    metadata: {
      ApiType: 'Azure'
      ResourceId: aiServicesId
    }
  }
}

@description('The resource ID of the AI Foundry Hub')
output id string = aiFoundryHub.id

@description('The name of the AI Foundry Hub')
output name string = aiFoundryHub.name
