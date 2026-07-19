targetScope = 'resourceGroup'

param location string = resourceGroup().location
param plsId string
param vnetName string = 'vnet-consumer'

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

          // DŮLEŽITÉ: správný groupId pro PLS
          groupIds: [
            'loadBalancerFrontend'
          ]

          requestMessage: 'Requesting access from consumer environment'
        }
      }
    ]
  }
}

output peId string = pe.id
