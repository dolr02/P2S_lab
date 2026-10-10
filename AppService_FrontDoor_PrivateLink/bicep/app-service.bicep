
param location string = 'Central India'
param webAppName string
param appServicePlanName string = 'asp-afd-private-link'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: appServicePlanName
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      http20Enabled: true
    }
  }
}

output webAppName string = webApp.name
output webAppId string = webApp.id
output webAppDefaultHostName string = webApp.properties.defaultHostName

