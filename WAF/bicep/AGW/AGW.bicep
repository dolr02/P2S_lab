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


// Existing AGW subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}


// Public IP for Application Gateway
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



// Application Gateway WAF_v2
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
        name: 'frontendPublicIP'

        properties: {
          publicIPAddress: {
            id: frontendPublicIpId
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
        name: 'backendHttpSettings'

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
        name: 'httpListener'

        properties: {

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGw.name,
              'frontendPublicIP'
            )
          }


          frontendPort: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGw.name,
              'frontendPort80'
            )
          }


          protocol: 'Http'
        }
      }
    ]


    requestRoutingRules: [
      {
        name: 'basicRule'

        properties: {

          ruleType: 'Basic'


          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGw.name,
              'httpListener'
            )
          }


          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGw.name,
              'backendPool'
            )
          }


          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGw.name,
              'backendHttpSettings'
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

  }
}
