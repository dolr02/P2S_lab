param location string = resourceGroup().location

@description('Resource ID of existing ILB frontend IP configuration')
param ilbFrontendId string

@description('Resource ID of existing ILB backend pool')
param ilbBackendPoolId string

@description('Resource ID of subnet for Private Link Service')
param plsSubnetId string

@description('Name of the Private Link Service')
param plsName string = 'pls-dev'

resource pls 'Microsoft.Network/privateLinkServices@2023-05-01' = {
  name: plsName
  location: location
  properties: {
    loadBalancerFrontendIpConfigurations: [
      {
        id: ilbFrontendId
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
