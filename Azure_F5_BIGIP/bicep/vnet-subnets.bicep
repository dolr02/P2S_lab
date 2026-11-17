targetScope = 'resourceGroup'

param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-f5-lab'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.73.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-f5-mgmt'
        properties: {
          addressPrefix: '10.73.0.0/24'
        }
      }
      {
        name: 'snet-f5-external'
        properties: {
          addressPrefix: '10.73.1.0/24'
        }
      }
      {
        name: 'snet-f5-internal'
        properties: {
          addressPrefix: '10.73.2.0/24'
        }
      }
    ]
  }
}
