targetScope = 'resourceGroup'

param location string = resourceGroup().location
param plsId string
param vnetName string = 'vnet-consumer'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnetName}/pe-subnet'
  properties: {
    addressPrefix: '10.10.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'consumer-pe'
  location: location
  properties: {
    subnet: {
      id: peSubnet.id
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
