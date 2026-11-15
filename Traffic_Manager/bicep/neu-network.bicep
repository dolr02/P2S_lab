targetScope = 'resourceGroup'

param location string = 'NorthEurope'

resource weuVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-dev-weu-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-web-weu-01'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

output vnetName string = weuVnet.name
output subnetName string = 'snet-web-weu-01'
