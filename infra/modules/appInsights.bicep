@description('Name of the Application Insights resource')
param name string

@description('Location for the resource')
param location string

@description('Resource ID of the Log Analytics Workspace')
param logAnalyticsWorkspaceId string

@description('Tags to apply to the resource')
param tags object = {}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId
  }
}

@description('The resource ID of the Application Insights resource')
output id string = appInsights.id

@description('The connection string for Application Insights')
output connectionString string = appInsights.properties.ConnectionString

@description('The instrumentation key for Application Insights')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('The name of the Application Insights resource')
output name string = appInsights.name
