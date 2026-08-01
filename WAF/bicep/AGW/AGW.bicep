param location string = resourceGroup().location

param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'

param appGwName string = 'p2slab-appgw'
param publicIpName string = 'p2slab-appgw-pip'


// VM PRIVATE IPs
param vmImageIp string
param vmVideoIp string



resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}


// PUBLIC IP

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



// APPLICATION GATEWAY

resource appGw 'Microsoft.Network/applicationGateways@2022-09-01' = {

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
        name: 'appGatewayIpConfig'

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



    backendAddressPools: [

      {
        name: 'pool-image'

        properties: {

          backendAddresses: [

            {
              ipAddress: vmImageIp
            }

          ]

        }
      }


      {
        name: 'pool-video'

        properties: {

          backendAddresses: [

            {
              ipAddress: vmVideoIp
            }

          ]

        }
      }

    ]



    backendHttpSettingsCollection: [

      {
        name: 'http80'

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
        name: 'listener-image'

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


      {
        name: 'listener-video'

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



    requestRoutingRules: [

      {
        name: 'rule-image'

        properties: {

          ruleType: 'Basic'

          priority: 100


          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGwName,
              'listener-image'
            )
          }


          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGwName,
              'pool-image'
            )
          }


          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGwName,
              'http80'
            )
          }

        }

      }


      {
        name: 'rule-video'

        properties: {

          ruleType: 'Basic'

          priority: 200


          httpListener: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/httpListeners',
              appGwName,
              'listener-video'
            )
          }


          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendAddressPools',
              appGwName,
              'pool-video'
            )
          }


          backendHttpSettings: {
            id: resourceId(
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection',
              appGwName,
              'http80'
            )
          }

        }

      }

    ]

  }

}
