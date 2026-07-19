targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Existing VNet name')
param vnetName string = 'vnet-dev-eus-01'

@description('Resource ID of existing Internal Load Balancer Frontend IP Configuration')
param ilbFrontendId string

@description('Private Link Service name')
param plsName string = 'pls-dev-eus-01'

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource plsSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnet.name}/pls-subnet'

  properties: {
    addressPrefix: '10.0.2.0/24'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource privateLinkService 'Microsoft.Network/privateLinkServices@2023-05-01' = {
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
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'

          subnet: {
            id: plsSubnet.id
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

  dependsOn: [
    plsSubnet
  ]
}

output privateLinkServiceId string = privateLinkService.id
