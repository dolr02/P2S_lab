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

@description('Protokol sondy dostupnosti.')
@allowed([
  'HTTP'
  'HTTPS'
])
param monitorProtocol string = 'HTTP'

@description('Port sondy dostupnosti.')
@minValue(1)
@maxValue(65535)
param monitorPort int = 80

@description('HTTP cesta kontrolovaná sondou.')
param monitorPath string = '/'

@description('Interval sond v sekundách.')
@allowed([
  10
  30
])
param probeInterval int = 30

@description('Timeout sondy. Pro interval 10 s použij hodnotu 5–9 s.')
@minValue(5)
@maxValue(10)
param probeTimeout int = 10

@description('Počet tolerovaných neúspěšných sond.')
@minValue(0)
@maxValue(9)
param toleratedFailures int = 3

@description('Název veřejné IP Azure LB ve stejné resource group.')
param azurePublicIpName string = ''

@description('DNS název on-prem webu, bez http:// nebo https://.')
param onpremFqdn string = ''

// Primární Azure větev.
var azureEndpoints = empty(azurePublicIpName) ? [] : [
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

// Záložní on-prem větev.
var onpremEndpoints = empty(onpremFqdn) ? [] : [
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

    endpoints: concat(azureEndpoints, onpremEndpoints)
  }
}

output profileId string = trafficManager.id
output trafficManagerFqdn string = trafficManager.properties.dnsConfig.fqdn
