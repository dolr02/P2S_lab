@description('Name of Public IP')
param pipName string

@description('Location')
param location string = resourceGroup().location


// Public IP
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


// Load Balancer
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


          // IMPORTANT:
          // because same frontend IP is used by outbound rule
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

          frontendIPConfigurations: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/frontendIPConfigurations',
                'lb-dev-eus-01',
                'fe-az700-eus-dev-01'
              )
            }
          ]

          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              'lb-dev-eus-01',
              'be-az700-eus-dev-01'
            )
          }

          protocol: 'All'

          allocatedOutboundPorts: 1024

          idleTimeoutInMinutes: 15
        }
      }
    ]
  }
}
