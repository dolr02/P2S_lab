@description('Public IP name')
param pipName string

param location string = resourceGroup().location


// Public IP - Standard SKU
resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: pipName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}


// Standard Load Balancer
resource lb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: 'lb-dev-eus-01'
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {

    frontendIPConfigurations: [
      {
        name: 'fe-az700-eus-dev-01'

        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]


    backendAddressPools: [
      {
        name: 'be-az700-eus-dev-01'
      }
    ]


    probes: [
      {
        name: 'hp-az700-eus-dev-01'

        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]


    loadBalancingRules: [
      {
        name: 'lbr-az700-eus-dev-01'

        properties: {

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              'lb-dev-eus-01',
              'fe-az700-eus-dev-01'
            )
          }


          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              'lb-dev-eus-01',
              'be-az700-eus-dev-01'
            )
          }


          probe: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/probes',
              'lb-dev-eus-01',
              'hp-az700-eus-dev-01'
            )
          }


          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80


          // IMPORTANT FOR STANDARD LB + OUTBOUND RULE
          disableOutboundSnat: true

          enableFloatingIP: false
          idleTimeoutInMinutes: 4
        }
      }
    ]


    outboundRules: [
      {
        name: 'or-az700-eus-dev-01'

        properties: {

          allocatedOutboundPorts: 1024

          protocol: 'All'


          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              'lb-dev-eus-01',
              'be-az700-eus-dev-01'
            )
          }


          frontendIPConfigurations: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/frontendIPConfigurations',
                'lb-dev-eus-01',
                'fe-az700-eus-dev-01'
              )
            }
          ]


          idleTimeoutInMinutes: 15
        }
      }
    ]
  }
}
