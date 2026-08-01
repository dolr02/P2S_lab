param location string = 'eastus'

param vnetName string
param subnetName string

param appGwName string = 'p2slab-appgw'
param publicIpName string = 'p2slab-appgw-pip'


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}


resource appGwSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
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


  properties: {

    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }


    gatewayIPConfigurations: [
      {
        name: 'gatewayIpConfig'

        properties: {
          subnet: {
            id: appGwSubnet.id
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
      }
    ]


    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'

        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
        }
      }
    ]


    httpListeners: [
      {
        name: 'listener80'

        properties: {

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGwName,
              'frontendPublicIp'
            )
          }

          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGwName,
              'port80'
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

          priority: 100

          ruleType: 'Basic'

          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGwName,
              'listener80'
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
              'httpSettings'
            )
          }
        }
      }
    ]


    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
  }
}
