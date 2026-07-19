targetScope = 'resourceGroup'

param location string = resourceGroup().location
param plsId string

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'consumer-pe'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'Microsoft.Network/virtualNetworks/subnets',
        'vnet-consumer',
        'pe-subnet'
      )
    }
    privateLinkServiceConnections: [
      {
        name: 'pls-connection'
        properties: {
          privateLinkServiceId: plsId
          groupIds: [
            'loadBalancerFrontend'
          ]
          requestMessage: 'Consumer requesting access'
        }
      }
    ]
  }
}

output peId string = pe.id
