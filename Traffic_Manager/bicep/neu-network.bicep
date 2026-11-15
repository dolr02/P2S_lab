targetScope = 'resourceGroup'

param location string = 'northeurope'

resource neuVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-dev-neu-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-web-neu-01'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

output vnetName string = neuVnet.name
output subnetName string = 'snet-web-neu-01'
