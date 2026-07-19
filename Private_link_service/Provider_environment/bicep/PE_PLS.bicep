targetScope = 'resourceGroup'

param location string = resourceGroup().location
param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'
param plsName string = 'pls-dev-eus-01'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: subnetName
  parent: vnet
}

//
// PLS SUBNET
//
resource plsSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${vnetName}/pls-subnet'
  properties: {
    addressPrefix: '10.0.2.0/24'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

//
// INTERNAL LOAD BALANCER
//
resource ilb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: 'ilb-dev'
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
            id: appSubnet.id
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
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'ilb-dev', 'ilb-fe')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'ilb-dev', 'ilb-be')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', 'ilb-dev', 'tcp-80')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
        }
      }
    ]
  }
}

//
// PLS
//
resource privateLinkService 'Microsoft.Network/privateLinkServices@2023-05-01' = {
  name: plsName
  location: location
  properties: {
    loadBalancerFrontendIpConfigurations: [
      {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'ilb-dev', 'ilb-fe')
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
  }
}

output privateLinkServiceId string = privateLinkService.id
output ilbBackendPoolId string = ilb.properties.backendAddressPools[0].id

