param location string = 'eastus'

param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'

param appGwName string = 'p2slab-appgw'
param publicIpName string = 'p2slab-appgw-pip'


resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}


resource publicIp 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIpName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}


resource appGw 'Microsoft.Network/applicationGateways@2022-09-01' = {

  name: appGwName
  location: location


  properties: {

    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
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
        name: 'port80'

        properties: {
          port: 80
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
              'frontendPublicIP'
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


    backendAddressPools: [
      {
        name: 'emptyBackend'

        properties: {}
      }
    ]


    backendHttpSettingsCollection: [
      {
        name: 'backendSettings'

        properties: {

          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'

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
              'listener80'
            )
          }

          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGwName,
              'emptyBackend'
            )
          }

          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGwName,
              'backendSettings'
            )
          }
        }
      }
    ]


    webApplicationFirewallConfiguration: {

      enabled: true

      firewallMode: 'Detection'

      ruleSetType: 'OWASP'

      ruleSetVersion: '3.2'
    }

  }
}
