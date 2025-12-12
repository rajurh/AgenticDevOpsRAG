@description('Location for resources')
param location string
param suffix string
param acrName string
param envName string
param containerAppName string

// Create ACR
resource acr 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Log Analytics workspace
resource logWs 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: concat('logws-', suffix)
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

// Container Apps managed environment
resource containerEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: envName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWs.properties.customerId
        sharedKey: listKeys(logWs.id, '2020-08-01').primarySharedKey
      }
    }
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: containerEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8000
        transport: 'Auto'
      }
      secrets: [
        {
          name: 'acrpassword'
          value: listCredentials(acr.id, '2019-05-01').passwords[0].value
        }
      ]
      registries: [
        {
          server: acr.properties.loginServer
          username: listCredentials(acr.id, '2019-05-01').username
          passwordSecretRef: 'acrpassword'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'agentic-rag-app'
          // Use a public placeholder image so deployment succeeds; update to the ACR image after push
          image: 'nginx:1.26.3'
        }
      ]
    }
  }
  dependsOn: [acr, containerEnv]
}

output acrName string = acr.name
output acrLoginServer string = acr.properties.loginServer
output containerEnvironmentName string = containerEnv.name
output containerAppName string = containerApp.name
output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
