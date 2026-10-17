param location string = resourceGroup().location

resource vnet1 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-1'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }

    subnets: [
      {
        name: 'snet-dc01'

        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
    ]
  }
}

output vnetName string = vnet1.name
output subnetName string = 'snet-dc01'
