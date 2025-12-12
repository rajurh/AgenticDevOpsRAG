@description('Location for all resources')
param location string = 'australiaeast'

// short suffix to make names unique per deployment
var suffix = toLower(substring(uniqueString(subscription().id, deployment().name), 0, 6))

var rgName = 'agentic-rg-${suffix}'
var acrName = toLower('agenticacr${suffix}')
var workspaceName = 'logws-${suffix}'
var envName = 'aca-env-${suffix}'
var containerAppName = 'agentic-app-${suffix}'

targetScope = 'subscription'

// Create the resource group for the app
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

// All resources below are deployed into the new resource group

module rgResources 'rgResources.bicep' = {
  name: 'rgResources'
  scope: resourceGroup(rg.name)
  params: {
    location: location
    suffix: suffix
    acrName: acrName
    envName: envName
    containerAppName: containerAppName
  }
}

output resourceGroupName string = rg.name
output acrName string = rgResources.outputs.acrName
output acrLoginServer string = rgResources.outputs.acrLoginServer
output containerEnvironmentName string = rgResources.outputs.containerEnvironmentName
output containerAppName string = rgResources.outputs.containerAppName
output containerAppFqdn string = rgResources.outputs.containerAppFqdn
