param location string = resourceGroup().location

param vnetName string
param subnetName string

param appGwName string = 'p2slab-appgw'
param publicIpName string = 'p2slab-appgw-pip'


// =====================
// EXISTING VNET
// =====================

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}


// =====================
// EXISTING AGW SUBNET
// =====================

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: subnetName
}


// =====================
// EXISTING VM NICs
// =====================

resource nicImage 'Microsoft.Network/networkInterfaces@2023-05-01' existing = {
  name: 'nic-image'
}

resource nicVideo 'Microsoft.Network/networkInterfaces@2023-05-01' existing = {
  name: 'nic-video'
}


// =====================
// PUBLIC IP
// =====================

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' = {

  name: publicIpName

  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}


// =====================
// APPLICATION GATEWAY
// =====================

resource appGw 'Microsoft.Network/applicationGateways@2023-05-01' = {

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
        name: 'gateway-ip-config'

        properties: {

          subnet: {

            id: subnet.id

          }

        }

      }

    ]



    frontendIPConfigurations: [

      {
        name: 'frontend-public-ip'

        properties: {

          publicIPAddress: {

            id: publicIp.id

          }

        }

      }

    ]



    frontendPorts: [

      {
        name: 'frontend-port-80'

        properties: {

          port: 80

        }

      }

    ]



    // =====================
    // BACKEND POOLS
    // =====================

    backendAddressPools: [

      {

        name: 'pool-image'


        properties: {

          backendIPConfigurations: [

            {
              id: nicImage.properties.ipConfigurations[0].id
            }

          ]

        }

      }


      {

        name: 'pool-video'


        properties: {

          backendIPConfigurations: [

            {
              id: nicVideo.properties.ipConfigurations[0].id
            }

          ]

        }

      }

    ]



    backendHttpSettingsCollection: [

      {

        name: 'backend-http'


        properties: {

          port: 80

          protocol: 'Http'

          cookieBasedAffinity: 'Disabled'

          requestTimeout: 30

        }

      }

    ]



    // =====================
    // LISTENER
    // =====================

    httpListeners: [

      {

        name: 'listener-http'


        properties: {

          frontendIPConfiguration: {

            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendIPConfigurations',
              appGwName,
              'frontend-public-ip'
            )

          }


          frontendPort: {

            id: resourceId(
              'Microsoft.Network/applicationGateways/frontendPorts',
              appGwName,
              'frontend-port-80'
            )

          }


          protocol: 'Http'

        }

      }

    ]



    // =====================
    // ROUTING
    // =====================

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
              'listener-http'
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
              'backend-http'
            )

          }

        }

      }

    ]

  }

}
