param location string
param vnetName string
param subnetName string
param publicIpName string
param appGwName string
param backendTargets array
param wafMode string


resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}


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


resource agw 'Microsoft.Network/applicationGateways@2022-09-01' = {

  name: appGwName
  location: location


  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
  }


  properties: {


    gatewayIPConfigurations: [
      {
        name: 'agw-ip-config'

        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]


    frontendIPConfigurations: [
      {
        name: 'frontend-ip'

        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]


    frontendPorts: [
      {
        name: 'port-80'

        properties: {
          port: 80
        }
      }
    ]


    backendAddressPools: [
      {
        name: 'backend-pool'

        properties: {
          backendAddresses: [
            for backend in backendTargets: {
              ipAddress: backend.ip
            }
          ]
        }
      }
    ]


    backendHttpSettingsCollection: [
      {
        name: 'http-settings'

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
        name: 'listener-http'

        properties: {

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGwName,
              'frontend-ip'
            )
          }


          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGwName,
              'port-80'
            )
          }


          protocol: 'Http'
        }
      }
    ]


    requestRoutingRules: [
      {
        name: 'rule-http'

        properties: {

          ruleType: 'Basic'


          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGwName,
              'listener-http'
            )
          }


          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGwName,
              'backend-pool'
            )
          }


          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGwName,
              'http-settings'
            )
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


    enableHttp2: true
  }
}


output appGatewayId string = agw.id
