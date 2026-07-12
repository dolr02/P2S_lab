@description('Location, e.g. eastus')
param location string = 'eastus'

@description('Name of the Load Balancer')
param lbName string = 'lb-dev-eus-01'

@description('Name of Public IP for LB frontend')
param pipName string = 'pip-dev-eus-lb-01'

@description('Frontend IP config name')
param feName string = 'fe-dev-eus-01'

@description('Backend pool name')
param bepName string = 'bep-dev-eus-01'

@description('Health probe name')
param probeName string = 'hp-dev-eus-01'

@description('LB rule name')
param lbRuleName string = 'lbr-dev-eus-01'

@description('Backend addresses (existing VM private IPs)')
param backendAddresses array = [
  {
    name: 'vm-dev-web-01-backend'
    ipAddress: '10.0.0.4'
  }
  {
    name: 'vm-dev-web-02-backend'
    ipAddress: '10.0.0.5'
  }
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
          loadBalancerBackendAddresses: [
            for addr in backendAddresses: {
              name: addr.name
              properties: {
                ipAddress: addr.ipAddress
              }
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
          intervalInSeconds: 5
          numberOfProbes: 2
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

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              lbName,
              feName
            )
          }
          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              lbName,
              bepName
            )
          }
          probe: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/probes',
              lbName,
              probeName
            )
          }
        }
      }
    ]
  }
}
