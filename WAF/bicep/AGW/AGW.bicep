param location string = resourceGroup().location

param vnetName string
param subnetName string

param appGwName string = 'p2slab-appgw'
param publicIpName string = 'p2slab-appgw-pip'


resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: subnetName
}


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


    backendAddressPools: [

      {
        name: 'pool-image'

        properties: {

          backendAddresses: [
            {
              ipAddress: '10.0.3.4'
            }
          ]

        }
      }


      {
        name: 'pool-video'

        properties: {

          backendAddresses: [
            {
              ipAddress: '10.0.2.4'
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


    httpListeners: [

      {
        name: 'listener-http'

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
