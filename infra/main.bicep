targetScope = 'subscription'

// ──────────────────────────────────────────────
// Parameters
// ──────────────────────────────────────────────

@description('Environment name (e.g. dev, staging, prod)')
param environmentName string

@description('Primary location for all resources')
param location string

@description('Name of the application')
@minLength(3)
param appName string = 'zavastore'

@description('SKU for App Service Plan')
param appServicePlanSku string = 'B1'

@description('SKU for Azure Container Registry')
param acrSku string = 'Basic'

@description('Docker image name and tag for the Web App')
param dockerImageAndTag string = 'zavastore:latest'

// ──────────────────────────────────────────────
// Variables
// ──────────────────────────────────────────────

var resourceGroupName = 'rg-${appName}-${environmentName}-${location}-yuki-${resourceSuffix}'
var tags = {
  environment: environmentName
  application: appName
  'azd-env-name': environmentName
}

// Resource naming (using consistent conventions with unique suffix for globally unique names)
var resourceSuffix = take(uniqueString(subscription().id, environmentName, location, 'yuki'), 6)
var acrName = replace('acr${appName}${environmentName}yuki${resourceSuffix}', '-', '')
var appServicePlanName = 'plan-${appName}-${environmentName}-yuki-${resourceSuffix}'
var webAppName = 'app-${appName}-${environmentName}-yuki-${resourceSuffix}'
var logAnalyticsName = 'log-${appName}-${environmentName}-yuki-${resourceSuffix}'
var appInsightsName = 'appi-${appName}-${environmentName}-yuki-${resourceSuffix}'
var aiServicesName = 'ais-${appName}-${environmentName}-yuki-${resourceSuffix}'
var aiFoundryHubName = 'hub-${appName}-${environmentName}-yuki-${resourceSuffix}'
var aiFoundryProjectName = 'proj-${appName}-${environmentName}-yuki-${resourceSuffix}'
var storageAccountName = take(replace(toLower('styuki${resourceSuffix}${appName}'), '-', ''), 24)
var keyVaultName = take(toLower('kv-${appName}-yuki-${resourceSuffix}'), 24)

// ──────────────────────────────────────────────
// Resource Group
// ──────────────────────────────────────────────

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ──────────────────────────────────────────────
// Monitoring
// ──────────────────────────────────────────────

module logAnalytics 'modules/logAnalytics.bicep' = {
  scope: resourceGroup
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

module appInsights 'modules/appInsights.bicep' = {
  scope: resourceGroup
  params: {
    name: appInsightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
    tags: tags
  }
}

// ──────────────────────────────────────────────
// Container Registry
// ──────────────────────────────────────────────

module acr 'modules/acr.bicep' = {
  scope: resourceGroup
  params: {
    name: acrName
    location: location
    sku: acrSku
    tags: tags
  }
}

// ──────────────────────────────────────────────
// App Service (Web App for Containers)
// ──────────────────────────────────────────────

module appServicePlan 'modules/appServicePlan.bicep' = {
  scope: resourceGroup
  params: {
    name: appServicePlanName
    location: location
    skuName: appServicePlanSku
    tags: tags
  }
}

module webApp 'modules/webApp.bicep' = {
  scope: resourceGroup
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    containerRegistryLoginServer: acr.outputs.loginServer
    dockerImageAndTag: dockerImageAndTag
    appInsightsConnectionString: appInsights.outputs.connectionString
    tags: tags
  }
}

// ──────────────────────────────────────────────
// RBAC: AcrPull role for Web App managed identity
// ──────────────────────────────────────────────

module acrPullRoleAssignment 'modules/roleAssignment.bicep' = {
  scope: resourceGroup
  params: {
    acrId: acr.outputs.id
    principalId: webApp.outputs.principalId
    principalType: 'ServicePrincipal'
  }
}

// ──────────────────────────────────────────────
// AI Services (Azure OpenAI / Cognitive Services)
// ──────────────────────────────────────────────

module aiServices 'modules/aiServices.bicep' = {
  scope: resourceGroup
  params: {
    name: aiServicesName
    location: location
    tags: tags
  }
}

// ──────────────────────────────────────────────
// AI Foundry Hub & Project
// ──────────────────────────────────────────────

module aiFoundry 'modules/aiFoundry.bicep' = {
  scope: resourceGroup
  params: {
    name: aiFoundryHubName
    location: location
    aiServicesId: aiServices.outputs.id
    aiServicesName: aiServices.outputs.name
    storageAccountName: storageAccountName
    keyVaultName: keyVaultName
    tags: tags
  }
}

module aiFoundryProject 'modules/aiFoundryProject.bicep' = {
  scope: resourceGroup
  params: {
    name: aiFoundryProjectName
    location: location
    aiFoundryHubId: aiFoundry.outputs.id
    tags: tags
  }
}

// ──────────────────────────────────────────────
// Outputs
// ──────────────────────────────────────────────

@description('The name of the resource group')
output AZURE_RESOURCE_GROUP string = resourceGroup.name

@description('The name of the Container Registry')
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name

@description('The login server of the Container Registry')
output AZURE_CONTAINER_REGISTRY_LOGIN_SERVER string = acr.outputs.loginServer

@description('The name of the Web App')
output AZURE_WEB_APP_NAME string = webApp.outputs.name

@description('The default hostname of the Web App')
output AZURE_WEB_APP_URL string = 'https://${webApp.outputs.defaultHostname}'

@description('The Application Insights connection string')
output AZURE_APPLICATION_INSIGHTS_CONNECTION_STRING string = appInsights.outputs.connectionString

@description('The AI Services endpoint')
output AZURE_AI_SERVICES_ENDPOINT string = aiServices.outputs.endpoint

@description('The AI Foundry Hub name')
output AZURE_AI_FOUNDRY_HUB_NAME string = aiFoundry.outputs.name

@description('The AI Foundry Project name')
output AZURE_AI_FOUNDRY_PROJECT_NAME string = aiFoundryProject.outputs.name
