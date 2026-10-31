param location string = resourceGroup().location

@description('Hub Virtual Network name')
param hubVnetName string = 'vnet-hub-eus-01'

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'snet-shared-services'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

output hubVnetId string = hubVnet.id
