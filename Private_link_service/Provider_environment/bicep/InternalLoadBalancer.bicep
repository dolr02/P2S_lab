param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: subnetName
  parent: vnet
}

resource ilb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: 'ilb-dev'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'ilb-fe'
        properties: {
          subnet: {
            id: subnet.id
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

output backendPoolId string = ilb.properties.backendAddressPools[0].id
