targetScope = 'resourceGroup'

param location string = resourceGroup().location

param vnetName string = 'vnet-dev-eus-01'
param gatewaySubnetName string = 'GatewaySubnet'

param appGwName string = 'p2slab-appgw'
param publicIpName string = 'p2slab-appgw-pip'

param skuCapacity int = 2

@allowed([
  'Detection'
  'Prevention'
])
param wafMode string = 'Prevention'


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}


resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: gatewaySubnetName
}


resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}


resource appGw 'Microsoft.Network/applicationGateways@2023-09-01' = {

  name: appGwName
  location: location


  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
    capacity: skuCapacity
  }


  properties: {

    gatewayIPConfigurations: [
      {
        name: 'gatewayIpConfig'

        properties: {
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]


    frontendIPConfigurations: [
      {
        name: 'frontendPublicIP'

        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]


    frontendPorts: [
      {
        name: 'frontendPort80'

        properties: {
          port: 80
        }
      }
    ]


    backendAddressPools: [
      {
        name: 'backendPool'

        properties: {}
      }
    ]


    backendHttpSettingsCollection: [
      {
        name: 'backendHttpSettings'

        properties: {

          port: 80
          protocol: 'Http'

          cookieBasedAffinity: 'Disabled'

          requestTimeout: 20
        }
      }
    ]


    httpListeners: [
      {
        name: 'httpListener'

        properties: {

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGwName,
              'frontendPublicIP'
            )
          }


          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGwName,
              'frontendPort80'
            )
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

          priority: 100


          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGwName,
              'httpListener'
            )
          }


          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGwName,
              'backendPool'
            )
          }


          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGwName,
              'backendHttpSettings'
            )
          }

        }
      }
    ]


    firewallPolicy: null


    webApplicationFirewallConfiguration: {

      enabled: true

      firewallMode: wafMode

      ruleSetType: 'OWASP'

      ruleSetVersion: '3.2'
    }

  }
}
