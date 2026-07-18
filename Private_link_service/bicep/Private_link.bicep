param location string = resourceGroup().location

// EXISTUJÍCÍ ILB

@description('Resource ID of existing ILB frontend')
param ilbFrontendId string

@description('Resource ID of existing ILB backend pool')
param ilbBackendPoolId string

// EXISTUJÍCÍ SUBNET (kde bude PLS)
@description('Resource ID of subnet for Private Link Service')
param plsSubnetId string

// PLS NAME
param plsName string = 'pls-dev'

// PRIVATE LINK SERVICE
resource pls 'Microsoft.Network/privateLinkServices@2023-05-01' = {
  name: plsName
  location: location
  properties: {
    loadBalancerFrontendIpConfigurations: [
      {
        id: ilbFrontendId
      }
    ]
    loadBalancerBackendAddressPools: [
      {
        id: ilbBackendPoolId
      }
    ]
    ipConfigurations: [
      {
        name: 'pls-ipconfig'
        properties: {
          subnet: {
            id: plsSubnetId
          }
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    enableProxyProtocol: false
    autoApproval: {
      subscriptions: []
    }
    visibility: {
      subscriptions: []
    }
  }
}
