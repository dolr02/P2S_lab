param location string = 'eastus'
param lbName string = 'lb-az700-dev-eus-01'
param frontendName string = 'fe-az700-dev-eus-01'
param backendPoolName string = 'be-az700-dev-eus-01'
param lbrName string = 'lbr-az700-dev-eus-01'
param outboundRuleName string = 'or-az700-dev-eus-01'
param probeName string = 'prb-az700-dev-eus-01'

@description('Resource ID veřejné IP adresy pro frontend LB')
param pipId string

resource lb 'Microsoft.Network/loadBalancers@2022-05-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendName
        properties: {
          publicIPAddress: {
            id: pipId
          }
        }
      }
    ]

    backendAddressPools: [
      {
        name: backendPoolName
      }
    ]

    probes: [
      {
        name: probeName
        properties: {
          protocol: 'Tcp'
          port: 80
        }
      }
    ]

    loadBalancingRules: [
      {
        name: lbrName
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          loadDistribution: 'Default'

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              lbName,
              frontendName
            )
          }

          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              lbName,
              backendPoolName
            )
          }

          probe: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/probes',
              lbName,
              probeName
            )
          }

          // ⭐ Povinné, protože sdílíš frontend IP s outbound rule
          disableOutboundSNAT: true
        }
      }
    ]

    outboundRules: [
      {
        name: outboundRuleName
        properties: {
          protocol: 'All'
          allocatedOutboundPorts: 1024

          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              lbName,
              backendPoolName
            )
          }

          frontendIPConfigurations: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/frontendIPConfigurations',
                lbName,
                frontendName
              )
            }
          ]
        }
      }
    ]
  }
}
