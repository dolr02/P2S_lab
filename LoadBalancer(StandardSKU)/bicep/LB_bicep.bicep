param location string = 'eastus'

param lbName string = 'lb-dev-eus-01'
param pipName string = 'pip-dev-eus-lb-01'
param feName string = 'fe-dev-eus-01'
param bepName string = 'bep-dev-eus-01'
param probeName string = 'hp-dev-eus-01'
param lbRuleName string = 'lbr-dev-eus-01'
param outboundRuleName string = 'or-dev-eus-01'

@description('NIC IDs to attach to backend pool')
param nicIds array = [
  '/subscriptions/<SUB>/resourceGroups/rg-az700-dev-eus/providers/Microsoft.Network/networkInterfaces/vm-dev-web-01-nic/ipConfigurations/ipconfig1',
  '/subscriptions/<SUB>/resourceGroups/rg-az700-dev-eus/providers/Microsoft.Network/networkInterfaces/vm-dev-web-02-nic/ipConfigurations/ipconfig1'
]

resource pip 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: pipName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2022-05-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: feName
        properties: {
          publicIPAddress: {
            id: pip.id
          }
        }
      }
    ]

    backendAddressPools: [
      {
        name: bepName
        properties: {
          backendIPConfigurations: [
            for nicId in nicIds: {
              id: nicId
            }
          ]
        }
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
        name: lbRuleName
        properties: {
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 4
          enableFloatingIP: false
          loadDistribution: 'Default'

          disableOutboundSNAT: true

          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, feName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, bepName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, probeName)
          }
        }
      }
    ]

    outboundRules: [
      {
        name: outboundRuleName
        properties: {
          protocol: 'All'
          allocatedOutboundPorts: 1024

          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, feName)
            }
          ]

          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, bepName)
          }
        }
      }
    ]
  }
}
