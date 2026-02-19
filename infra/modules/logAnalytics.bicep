@description('Name of the Log Analytics Workspace')
param name string

@description('Location for the resource')
param location string

@description('Tags to apply to the resource')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

@description('The resource ID of the Log Analytics Workspace')
output id string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics Workspace')
output name string = logAnalyticsWorkspace.name
