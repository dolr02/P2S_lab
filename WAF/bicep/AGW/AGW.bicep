param location string = resourceGroup().location

param vnetName string = 'vnet-dev-eus-01'

param subnetName string = 'GatewaySubnet'

param appGwName string = 'p2slab-appgw'

param publicIpName string = 'p2slab-appgw-pip'

param skuCapacity int = 2

@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Prevention'

param tags object = {}

param backendTargets array = []


// Existing VNET
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}


// GatewaySubnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}


// Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIpName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }

  tags: tags
}


// Application Gateway
resource appGw 'Microsoft.Network/applicationGateways@2022-09-01' = {

  name: appGwName
  location: location

  tags: tags

  properties: {

    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: skuCapacity
    }


    gatewayIPConfigurations: [
      {
        name: 'gatewayIpConfig'

        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]


    frontendIPConfigurations: [
      {
        name: 'frontendPublicIp'

        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]


    frontendPorts: [
      {
        name: 'port80'

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
            for ip in backendTargets: {
              ipAddress: ip
            }
          ]
        }
      }
    ]


    backendHttpSettingsCollection: [
      {
        name: 'backendSettings'

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
        name: 'listener80'

        properties: {

          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGwName)}/frontendIPConfigurations/frontendPublicIp'
          }

          frontendPort: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGwName)}/frontendPorts/port80'
          }

          protocol: 'Http'
        }
      }
    ]


    requestRoutingRules: [
      {
        name: 'rule80'

        properties: {

          ruleType: 'Basic'

          httpListener: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGwName)}/httpListeners/listener80'
          }

          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGwName)}/backendAddressPools/backendPool'
          }

          backendHttpSettings: {
            id: '${resourceId('Microsoft.Network/applicationGateways', appGwName)}/backendHttpSettingsCollection/backendSettings'
          }

        }
      }
    ]


    webApplicationFirewallConfiguration: {

      enabled: true

      firewallMode: wafMode

      ruleSetType: 'OWASP'

      ruleSetVersion: '3.2'
    }

  }
}
