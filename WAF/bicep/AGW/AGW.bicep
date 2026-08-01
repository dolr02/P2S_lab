param location string = 'eastus'

param vnetName string
param subnetName string

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


  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
  }


  properties: {

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
        name: 'frontendPort80'

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
        name: 'backendHttpSettings'

        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
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

          priority: 100

          ruleType: 'Basic'


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


    enableHttp2: true


    firewallPolicy: null
  }
}
