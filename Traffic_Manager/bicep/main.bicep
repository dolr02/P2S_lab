targetScope = 'resourceGroup'

@description('Název profilu Traffic Manageru.')
param profileName string

@description('Globálně unikátní prefix adresy <prefix>.trafficmanager.net.')
@minLength(1)
@maxLength(63)
param dnsLabel string

@description('Doba platnosti DNS odpovědi v cache, v sekundách.')
@minValue(0)
@maxValue(2147483647)
param dnsTtl int = 30

@description('Protokol sondy dostupnosti backendové služby.')
@allowed([
  'HTTP'
  'HTTPS'
])
param monitorProtocol string = 'HTTP'

@description('Port sondy dostupnosti.')
@minValue(1)
@maxValue(65535)
param monitorPort int = 80

@description('HTTP cesta, kterou sonda kontroluje.')
param monitorPath string = '/'

@description('Interval sond: standardní 30 s nebo rychlý 10 s.')
@allowed([
  10
  30
])
param probeInterval int = 30

@description('Časový limit sondy v sekundách. Pro interval 30 s použijeme 10 s.')
@minValue(5)
@maxValue(10)
param probeTimeout int = 10

@description('Počet tolerovaných neúspěšných sond.')
@minValue(0)
@maxValue(9)
param toleratedFailures int = 3

@description('Název veřejné IP adresy, která má být přidána jako endpoint Traffic Manageru.')
param azurePublicIpName string = ''

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
    endpoints: empty(azurePublicIpName) ? [] : [
  {
    name: 'azure-lb'
    type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
    properties: {
      targetResourceId: resourceId(
        'Microsoft.Network/publicIPAddresses',
        azurePublicIpName
      )
      endpointStatus: 'Enabled'
      priority: 1
    }
  }
]
  }
}

output profileId string = trafficManager.id
output trafficManagerFqdn string = trafficManager.properties.dnsConfig.fqdn
