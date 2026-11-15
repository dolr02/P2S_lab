targetScope = 'resourceGroup'

param profileName string = 'tm-performance-lab'
param dnsLabel string = 'tm-performance-lab-dolr02-01'

resource eastUsPip 'Microsoft.Network/publicIPAddresses@2023-09-01' existing = {
  name: 'pip-dev-eus-lb-01'
}

resource northEuropePip 'Microsoft.Network/publicIPAddresses@2023-09-01' existing = {
  name: 'pip-web-neu-01'
}

resource trafficManager 'Microsoft.Network/trafficManagerProfiles@2022-04-01' = {
  name: profileName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'

    dnsConfig: {
      relativeName: dnsLabel
      ttl: 30
    }

    monitorConfig: {
      protocol: 'HTTP'
      port: 80
      path: '/'
      intervalInSeconds: 30
      timeoutInSeconds: 10
      toleratedNumberOfFailures: 3
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 200
        }
      ]
    }

    endpoints: [
      {
        name: 'eastus-lb'
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          targetResourceId: eastUsPip.id
          endpointStatus: 'Enabled'
        }
      }
      {
        name: 'northeurope-web'
        type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
        properties: {
          targetResourceId: northEuropePip.id
          endpointStatus: 'Enabled'
        }
      }
    ]
  }
}

output trafficManagerFqdn string = trafficManager.properties.dnsConfig.fqdn
output profileId string = trafficManager.id
