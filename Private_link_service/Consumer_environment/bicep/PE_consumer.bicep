targetScope = 'resourceGroup'

param location string = resourceGroup().location
param plsId string
param peSubnetId string

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'consumer-pe'
  location: location
  properties: {
    subnet: {
      id: peSubnetId
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
