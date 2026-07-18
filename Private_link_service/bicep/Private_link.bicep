param location string = resourceGroup().location

// EXISTUJÍCÍ ILB

@description('Resource ID of existing ILB frontend')
param ilbFrontendId string

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
    // backend pool is not a supported property for this API version; backend association
    // is achieved via the IP configuration and the load balancer frontend
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
