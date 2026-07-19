targetScope = 'resourceGroup'

param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-provider'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'app-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'pls-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

resource ilb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: 'ilb-provider'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'ilb-fe'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAddress: '10.0.1.100'
          privateIPAllocationMethod: 'Static'
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'ilb-be'
      }
    ]
    probes: [
      {
        name: 'tcp-80'
        properties: {
          protocol: 'Tcp'
          port: 80
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'http-rule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'ilb-provider', 'ilb-fe')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'ilb-provider', 'ilb-be')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', 'ilb-provider', 'tcp-80')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
        }
      }
    ]
  }
}

resource pls 'Microsoft.Network/privateLinkServices@2023-05-01' = {
  name: 'pls-provider'
  location: location
  properties: {
    loadBalancerFrontendIpConfigurations: [
      {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'ilb-provider', 'ilb-fe')
      }
    ]
    ipConfigurations: [
      {
        name: 'pls-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
      }
    ]
  }
}

output plsId string = pls.id
output backendPoolId string = ilb.properties.backendAddressPools[0].id
