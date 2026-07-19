targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vnetName string = 'vnet-consumer-eus-01'
param plsId string  // ID Private Link Service z provider RG

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'consumer-pe'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'Microsoft.Network/virtualNetworks/subnets',
        vnetName,
        'pe-subnet'
      )
    }
    privateLinkServiceConnections: [
      {
        name: 'pls-connection'
        properties: {
          privateLinkServiceId: plsId
          groupIds: [
            'endpoint'
          ]
          requestMessage: 'Requesting access from consumer environment'
        }
      }
    ]
  }
}

output peId string = pe.id
