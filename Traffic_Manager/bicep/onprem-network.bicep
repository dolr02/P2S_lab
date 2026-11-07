param location string = resourceGroup().location

resource onpremVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-onprem-eus-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
    subnets: [
      {
        name: 'snet-onprem'
        properties: {
          addressPrefix: '192.168.1.0/24'
        }
      }
    ]
  }
}

output vnetName string = onpremVnet.name
output subnetName string = 'snet-onprem'
