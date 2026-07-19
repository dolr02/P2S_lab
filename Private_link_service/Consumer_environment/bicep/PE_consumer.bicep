targetScope = 'resourceGroup'

param location string = resourceGroup().location
param plsId string

//
// CONSUMER VNET
//
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-consumer'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'pe-subnet'
        properties: {
          addressPrefix: '10.10.2.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

//
// PRIVATE ENDPOINT
//
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
          requestMessage: 'Requesting access from consumer environment'
        }
      }
    ]
  }
}

output peId string = pe.id
