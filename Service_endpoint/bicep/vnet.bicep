targetScope = 'resourceGroup'

@description('Location')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-p2s-lab'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }

    subnets: [
      {
        name: 'default-subnet'
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
      {
        name: 'storage-se-subnet'
        properties: {
          addressPrefix: '10.10.2.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

output vnetName string = vnet.name
