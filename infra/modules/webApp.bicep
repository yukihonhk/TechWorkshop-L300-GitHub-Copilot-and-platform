@description('Name of the Web App')
param name string

@description('Location for the resource')
param location string

@description('Resource ID of the App Service Plan')
param appServicePlanId string

@description('Login server URL of the Container Registry')
param containerRegistryLoginServer string

@description('Docker image name and tag')
param dockerImageAndTag string = 'zavastore:latest'

@description('Application Insights connection string')
param appInsightsConnectionString string

@description('Tags to apply to the resource')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/${dockerImageAndTag}'
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryLoginServer}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'WEBSITES_PORT'
          value: '8080'
        }
      ]
    }
  }
}

@description('The resource ID of the Web App')
output id string = webApp.id

@description('The default hostname of the Web App')
output defaultHostname string = webApp.properties.defaultHostName

@description('The name of the Web App')
output name string = webApp.name

@description('The principal ID of the system-assigned managed identity')
output principalId string = webApp.identity.principalId
