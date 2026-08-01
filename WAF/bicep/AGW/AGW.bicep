param location string = resourceGroup().location

param vnetName string
param subnetName string

param appGwName string = 'p2slab-appgw'
param publicIpName string = 'p2slab-appgw-pip'

param vmImageIp string

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: subnetName
}

resource pip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: publicIpName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource agw 'Microsoft.Network/applicationGateways@2023-05-01' = {
  name: appGwName
  location: location

  properties: {

    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }

    gatewayIPConfigurations: [
      {
        name: 'gateway'
        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]

    frontendIPConfigurations: [
      {
        name: 'frontend'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]

    frontendPorts: [
      {
        name: 'http'
        properties: {
          port: 80
        }
      }
    ]

    backendAddressPools: [
      {
        name: 'pool'
        properties: {
          backendAddresses: [
            {
              ipAddress: vmImageIp
            }
          ]
        }
      }
    ]

    backendHttpSettingsCollection: [
      {
        name: 'http'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
        }
      }
    ]

    httpListeners: [
      {
        name: 'listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'frontend')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'http')
          }
          protocol: 'Http'
        }
      }
    ]

    requestRoutingRules: [
      {
        name: 'rule'
        properties: {
          ruleType: 'Basic'
          priority: 100

          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'listener')
          }

          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'pool')
          }

          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'http')
          }
        }
      }
    ]
  }
}
