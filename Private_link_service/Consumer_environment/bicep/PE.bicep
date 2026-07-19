param location string = resourceGroup().location

param plsId string


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-consumer'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }

    subnets: [
      {
        name: 'snet-private-endpoint'

        properties: {
          addressPrefix: '10.1.1.0/24'

          privateEndpointNetworkPolicies: 'Disabled'
        }
      }

      {
        name: 'snet-vm'

        properties: {
          addressPrefix: '10.1.2.0/24'
        }
      }
    ]
  }
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: 'pe-provider-service'

  location: location

  properties: {

    subnet: {
      id: resourceId(
        'Microsoft.Network/virtualNetworks/subnets',
        vnet.name,
        'snet-private-endpoint'
      )
    }

    privateLinkServiceConnections: [
      {
        name: 'pls-connection'

        properties: {
          privateLinkServiceId: plsId

          requestMessage: 'Consumer request to provider PLS'
        }
      }
    ]
  }
}


output privateEndpointId string = privateEndpoint.id
