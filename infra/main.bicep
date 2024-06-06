targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
@allowed(['australiaeast', 'eastus', 'eastus2', 'francecentral', 'norwayeast', 'swedencentral', 'uksouth'])
param location string

@description('The Azure resource group where new resources will be deployed')
param resourceGroupName string = ''
@description('The Azure AI Studio Hub resource name. If ommited will be generated')
param aiHubName string = ''
@description('The Azure AI Studio project name. If ommited will be generated')
param aiProjectName string = ''
@description('The application insights resource name. If ommited will be generated')
param appInsightsName string = ''
@description('The Open AI resource name. If ommited will be generated')
param openAiName string = ''
@description('The Azure Container Registry resource name. If ommited will be generated')
param containerRegistryName string = ''
@description('The Azure Key Vault resource name. If ommited will be generated')
param keyVaultName string = ''
@description('The Azure Storage Account resource name. If ommited will be generated')
param storageAccountName string = ''
@description('The log analytics workspace name. If ommited will be generated')
param logAnalyticsName string = ''
@description('The name of the machine learning online endpoint. If ommited will be generated')
param endpointName string = ''
@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Id of the user or app to assign application roles')
param principalType string = 'User'

// --- These were not defined in other samples
param cosmosAccountName string = ''
param searchServiceName string = ''
param aiResourceGroupName string = ''
// --------------------

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

var actualCosmosAccountName = !empty(cosmosAccountName)
  ? cosmosAccountName
  : '${abbrs.documentDBDatabaseAccounts}${resourceToken}'

var openAiConfig = loadYamlContent('./ai.yaml')
var openAiModelDeployments = array(contains(openAiConfig, 'deployments') ? openAiConfig.deployments : [])

module cosmos 'core/database/cosmos/sql/cosmos-sql-db.bicep' = {
  name: 'cosmos'
  scope: rg
  params: {
    accountName: actualCosmosAccountName
    databaseName: 'contoso-outdoor'
    location: location
    tags: union(
      tags,
      {
        defaultExperience: 'Core (SQL)'
        'hidden-cosmos-mmspecial': ''
      }
    )
    keyVaultName: ai.outputs.keyVaultName
    aiServicePrincipalId: ai.outputs.projectPrincipalId
    containers: [
      {
        name: 'customers'
        id: 'customers'
        partitionKey: '/id'
      }
    ]
  }
}

module ai 'core/host/ai-environment.bicep' = {
  name: 'ai'
  scope: resourceGroup(!empty(aiResourceGroupName) ? aiResourceGroupName : rg.name)
  params: {
    location: location
    tags: tags
    hubName: !empty(aiHubName) ? aiHubName : 'ai-hub-${resourceToken}'
    projectName: !empty(aiProjectName) ? aiProjectName : 'ai-project-${resourceToken}'
    logAnalyticsName: !empty(logAnalyticsName)
      ? logAnalyticsName
      : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    appInsightsName: !empty(appInsightsName) ? appInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    containerRegistryName: !empty(containerRegistryName)
      ? containerRegistryName
      : '${abbrs.containerRegistryRegistries}${resourceToken}'
    keyVaultName: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
    storageAccountName: !empty(storageAccountName)
      ? storageAccountName
      : '${abbrs.storageStorageAccounts}${resourceToken}'
    openAiName: !empty(openAiName) ? openAiName : 'aoai-${resourceToken}'
    openAiModelDeployments: openAiModelDeployments
    searchName: !empty(searchServiceName) ? searchServiceName : 'srch-${resourceToken}'
  }
}

module machineLearningEndpoint './core/host/ml-online-endpoint.bicep' = {
  name: 'endpoint'
  scope: resourceGroup(!empty(aiResourceGroupName) ? aiResourceGroupName : rg.name)
  params: {
    name: !empty(endpointName) ? endpointName : 'mloe-${resourceToken}'
    location: location
    tags: tags
    serviceName: 'chat'
    aiHubName: ai.outputs.hubName
    aiProjectName: ai.outputs.projectName
    keyVaultName: ai.outputs.keyVaultName
    roleDefinitionId: cosmos.outputs.roleDefinitionId
    accountName: cosmos.outputs.accountName
  }
}

module workspaceConnections 'app/workspace-connections.bicep' = {
  name: 'workspace-connections'
  scope: rg
  params: {
    aiHubName: ai.outputs.hubName
    aiResourceGroupName: !empty(aiResourceGroupName) ? aiResourceGroupName : rg.name
    cosmosAccounntName: cosmos.outputs.accountName
  }
}

module userAcrRolePush 'core/security/role.bicep' = {
  name: 'user-acr-role-push'
  scope: rg
  params: {
    principalId: principalId
    roleDefinitionId: '8311e382-0749-4cb8-b61a-304f252e45ec'
    principalType: principalType
  }
}

module userAcrRolePull 'core/security/role.bicep' = {
  name: 'user-acr-role-pull'
  scope: rg
  params: {
    principalId: principalId
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
    principalType: principalType
  }
}

module openaiRoleUser 'core/security/role.bicep' = if (!empty(principalId)) {
  scope: rg
  name: 'openai-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' //Cognitive Services OpenAI User
    principalType: principalType
  }
}

module openaiRoleBackend 'core/security/role.bicep' = {
  scope: rg
  name: 'openai-role-backend'
  params: {
    principalId: principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd' //Cognitive Services OpenAI User
    principalType: principalType
  }
}

module userRoleDataScientist 'core/security/role.bicep' = {
  name: 'user-role-data-scientist'
  scope: rg
  params: {
    principalId: principalId
    roleDefinitionId: 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
    principalType: principalType
  }
}

module userRoleSecretsReader 'core/security/role.bicep' = {
  name: 'user-role-secrets-reader'
  scope: rg
  params: {
    principalId: principalId
    roleDefinitionId: 'ea01e6af-a1c1-4350-9563-ad00f8c72ec5'
    principalType: principalType
  }
}

module userAiSearchRole 'core/security/role.bicep' = if (!empty(principalId)) {
  scope: rg
  name: 'user-ai-search-index-data-contributor'
  params: {
    principalId: principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7' //Search Index Data Contributor
    principalType: principalType
  }
}

module aiSearchRole 'core/security/role.bicep' = {
  scope: rg
  name: 'ai-search-index-data-contributor'
  params: {
    principalId: machineLearningEndpoint.outputs.principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7' //Search Index Data Contributor
    principalType: 'ServicePrincipal'
  }
}

module userAiSearchServiceContributor 'core/security/role.bicep' = if (!empty(principalId)) {
  scope: rg
  name: 'user-ai-search-service-contributor'
  params: {
    principalId: principalId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0' //Search Service Contributor
    principalType: principalType
  }
}

module aiSearchServiceContributor 'core/security/role.bicep' = {
  scope: rg
  name: 'ai-search-service-contributor'
  params: {
    principalId: machineLearningEndpoint.outputs.principalId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0' //Search Service Contributor
    principalType: 'ServicePrincipal'
  }
}

module userCosmosAccountRole 'core/security/role-cosmos.bicep' = if (!empty(principalId)) {
  scope: rg
  name: 'user-cosmos-account-role'
  params: {
    principalId: principalId
    databaseAccountId: cosmos.outputs.accountId
    databaseAccountName: cosmos.outputs.accountName
  }
}

module cosmosAccountRole 'core/security/role-cosmos.bicep' = {
  scope: rg
  name: 'cosmos-account-role'
  params: {
    principalId: machineLearningEndpoint.outputs.principalId
    databaseAccountId: cosmos.outputs.accountId
    databaseAccountName: cosmos.outputs.accountName
  }
}


// output the names of the resources
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name

output AZUREAI_HUB_NAME string = ai.outputs.hubName
output AZUREAI_PROJECT_NAME string = ai.outputs.projectName

output AZURE_OPENAI_NAME string = ai.outputs.openAiName
output AZURE_OPENAI_ENDPOINT string = ai.outputs.openAiEndpoint

output AZURE_COSMOS_NAME string = cosmos.outputs.accountName
output COSMOS_ENDPOINT string = cosmos.outputs.endpoint

output AZURE_SEARCH_NAME string = ai.outputs.searchName
output AZURE_SEARCH_ENDPOINT string = ai.outputs.searchEndpoint

output AZURE_CONTAINER_REGISTRY_NAME string = ai.outputs.containerRegistryName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = ai.outputs.containerRegistryEndpoint

output AZURE_KEY_VAULT_NAME string = ai.outputs.keyVaultName
output AZURE_KEY_VAULT_ENDPOINT string = ai.outputs.keyVaultEndpoint

