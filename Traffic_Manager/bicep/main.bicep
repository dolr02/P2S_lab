targetScope = 'resourceGroup'

param profileName string

@minLength(1)
@maxLength(63)
param dnsLabel string

@minValue(0)
@maxValue(2147483647)
param dnsTtl int = 30

@allowed([
  'HTTP'
  'HTTPS'
])
param monitorProtocol string = 'HTTP'

@minValue(1)
@maxValue(65535)
param monitorPort int = 80

param monitorPath string = '/'

@allowed([
  10
  30
])
param probeInterval int = 30

@minValue(5)
@maxValue(10)
param probeTimeout int = 10

@minValue(0)
@maxValue(9)
param toleratedFailures int = 3

@description('Existující podřízený Performance profil ve stejné resource group.')
param childProfileName string

@description('DNS jméno on-prem webu, bez http://.')
param onpremFqdn string

resource childProfile 'Microsoft.Network/trafficManagerProfiles@2022-04-01' existing = {
  name: childProfileName
}

resource trafficManager 'Microsoft.Network/trafficManagerProfiles@2022-04-01' = {
  name: profileName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'

    dnsConfig: {
      relativeName: dnsLabel
      ttl: dnsTtl
    }

    monitorConfig: {
      protocol: monitorProtocol
      port: monitorPort
      path: monitorPath
      intervalInSeconds: probeInterval
      timeoutInSeconds: probeTimeout
      toleratedNumberOfFailures: toleratedFailures
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 200
        }
      ]
    }

    endpoints: [
      {
        name: 'azure-regions'
        type: 'Microsoft.Network/trafficManagerProfiles/nestedEndpoints'
        properties: {
          targetResourceId: childProfile.id
          endpointStatus: 'Enabled'
          priority: 1
          minChildEndpoints: 1
        }
      }
      {
        name: 'onprem-web'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          target: onpremFqdn
          endpointStatus: 'Enabled'
          priority: 2
        }
      }
    ]
  }
}

output profileId string = trafficManager.id
output trafficManagerFqdn string = trafficManager.properties.dnsConfig.fqdn
