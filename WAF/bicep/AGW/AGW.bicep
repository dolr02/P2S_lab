param location string = resourceGroup().location
param appGwName string = 'myAppGw'
param vnetName string
param subnetName string
param publicIpName string = 'myAppGwPip'
param backendIp string = '10.0.0.4'

// EXISTUJÍCÍ VNET
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}

// EXISTUJÍCÍ SUBNET
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}

// PUBLIC IP
resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// APPLICATION GATEWAY WAF_v2
resource appGw 'Microsoft.Network/applicationGateways@2022-09-01' = {
  name: appGwName
  location: location
  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
  }
  properties: {
    gatewayIPConfigurations: [
      {
        name: 'gwIpConfig'
        subnet: {
          id: subnet.id
        }
      }
    ]

    frontendIPConfigurations: [
      {
        name: 'frontendIp'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]

    frontendPorts: [
      {
        name: 'frontendPort'
        properties: {
          port: 80
        }
      }
    ]

    backendAddressPools: [
      {
        name: 'backendPool'
        properties: {
          backendAddresses: [
            {
              ipAddress: backendIp
            }
          ]
        }
      }
    ]

    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: 80
          protocol: 'Http'
        }
      }
    ]

    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, 'frontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGwName, 'frontendPort')
          }
          protocol: 'Http'
        }
      }
    ]

    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGwName, 'httpListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGwName, 'backendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, 'httpSettings')
          }
        }
      }
    ]
  }
}
