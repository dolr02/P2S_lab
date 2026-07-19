targetScope = 'resourceGroup'

param location string = resourceGroup().location


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-provider'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

    subnets: [

      {
        name: 'app-subnet'

        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }

      {
        name: 'pls-subnet'

        properties: {
          addressPrefix: '10.0.2.0/24'

          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}



resource ilb 'Microsoft.Network/loadBalancers@2023-09-01' = {

  name: 'ilb-provider'

  location: location

  sku: {
    name: 'Standard'
  }


  properties: {


    frontendIPConfigurations: [

      {
        name: 'frontend-private'

        properties: {

          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              vnet.name,
              'app-subnet'
            )
          }


          privateIPAddress: '10.0.1.100'

          privateIPAllocationMethod: 'Static'
        }
      }
    ]



    backendAddressPools: [

      {
        name: 'backend-pool'
      }
    ]



    probes: [

      {
        name: 'tcp-probe'

        properties: {

          protocol: 'Tcp'

          port: 80

        }
      }
    ]



    loadBalancingRules: [

      {
        name: 'http-rule'


        properties: {

          frontendIPConfiguration: {

            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              'ilb-provider',
              'frontend-private'
            )

          }


          backendAddressPool: {

            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              'ilb-provider',
              'backend-pool'
            )

          }


          probe: {

            id: resourceId(
              'Microsoft.Network/loadBalancers/probes',
              'ilb-provider',
              'tcp-probe'
            )

          }


          protocol: 'Tcp'

          frontendPort: 80

          backendPort: 80

        }
      }
    ]
  }
}



resource pls 'Microsoft.Network/privateLinkServices@2023-05-01' = {

  name: 'pls-provider'

  location: location


  dependsOn: [
    ilb
  ]


  properties: {


    loadBalancerFrontendIpConfigurations: [

      {

        id: resourceId(
          'Microsoft.Network/loadBalancers/frontendIPConfigurations',
          'ilb-provider',
          'frontend-private'
        )

      }
    ]



    ipConfigurations: [

      {

        name: 'pls-ipconfig'


        properties: {


          privateIPAllocationMethod: 'Dynamic'


          subnet: {

            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              vnet.name,
              'pls-subnet'
            )

          }

        }
      }
    ]
  }
}



output plsId string = pls.id


output ilbId string = ilb.id


output backendPoolId string = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  'ilb-provider',
  'backend-pool'
)
