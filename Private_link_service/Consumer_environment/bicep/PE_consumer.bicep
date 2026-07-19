targetScope = 'resourceGroup'

param location string = resourceGroup().location

// FULL resource ID PLS z provider RG
param plsId string

// VNET name v consumer RG
param vnetName string = 'vnet-consumer'

// PE subnet name
param peSubnetName string = 'pe-subnet'

// ----------------------
// PRIVATE ENDPOINT
// ----------------------
resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'consumer-pe'
  location: location
  properties: {
    subnet: {
      id: resourceId(
        'Microsoft.Network/virtualNetworks/subnets',
        vnetName,
        peSubnetName
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
