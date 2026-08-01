// AGW.bicep

param location string = resourceGroup().location

param vnetResourceGroup string = resourceGroup().name
param vnetName string = 'vnet-dev-eus-01'

param subnetName string = 'snet-agw-dev-eus-01'

param appGwName string = 'p2slab-appgw'

param existingPublicIpId string = ''

param skuCapacity int = 2

@allowed([
  'Prevention'
  'Detection'
])
param wafMode string = 'Prevention'

param backendTargets array = []

param tags object = {}


// Existing VNET
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}


// Dedicated Application Gateway subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}


// Public IP
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-09-01' = if (empty(existingPublicIpId)) {
  name: '${appGwName}-pip'
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }

  tags: tags
}


var frontendPublicIpId = empty(existingPublicIpId)
  ? publicIp.id
  : existingPublicIpId



// Application Gateway WAF v2
resource appGw 'Microsoft.Network/applicationGateways@2022-05-01' = {

  name: appGwName
  location: location

  tags: tags


  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
    capacity: skuCapacity
  }


  properties: {


    gatewayIPConfigurations: [
      {
        name: 'appGwIpConfig'

        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]



    frontendIPConfigurations: [
      {
        name: 'appGwFrontendIP'

        properties: {
          publicIPAddress: {
            id: frontendPublicIpId
          }
        }
      }
    ]



    frontendPorts: [
      {
        name: 'httpPort'

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
            for target in backendTargets: {
              ipAddress: target
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

          cookieBasedAffinity: 'Disabled'

          requestTimeout: 30

        }
      }
    ]



    probes: [
      {
        name: 'healthProbe'

        properties: {

          protocol: 'Http'

          path: '/'

          interval: 30

          timeout: 30

          unhealthyThreshold: 3

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
              'appGwFrontendIP'
            )
          }


          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGwName,
              'httpPort'
            )
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
              'httpSettings'
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
