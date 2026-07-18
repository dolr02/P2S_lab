param location string = resourceGroup().location

@description('Resource ID of existing Internal Load Balancer frontend IP configuration')
param ilbFrontendId string

@description('Subnet ID dedicated for Private Link Service')
param plsSubnetId string

@description('Private Link Service name')
param plsName string = 'pls-dev-eus-01'


resource pls 'Microsoft.Network/privateLinkServices@2023-05-01' = {
  name: plsName
  location: location

  properties: {

    // Connect PLS to existing Internal Load Balancer frontend
    loadBalancerFrontendIpConfigurations: [
      {
        id: ilbFrontendId
      }
    ]

    // Private IP configuration for Private Link Service
    ipConfigurations: [
      {
        name: 'pls-ipconfig'

        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'

          subnet: {
            id: plsSubnetId
          }
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


output privateLinkServiceId string = pls.id
output privateLinkServiceName string = pls.name
