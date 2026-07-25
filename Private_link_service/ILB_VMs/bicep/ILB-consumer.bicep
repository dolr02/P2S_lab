targetScope = 'resourceGroup'

param location string = resourceGroup().location

var vnetName = 'vnet-consumer'
var subnetName = 'snet-vm'

var lbName = 'ilb-consumer'
var backendPoolName = 'consumer-backend-pool'
var frontendName = 'consumer-frontend-ip'
var probeName = 'consumer-http-probe'
var ruleName = 'consumer-http-rule'


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}


resource ilb 'Microsoft.Network/loadBalancers@2023-09-01' = {

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

          subnet: {
            id: subnet.id
          }

          privateIPAllocationMethod: 'Dynamic'
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

          intervalInSeconds: 15

          numberOfProbes: 2
        }
      }
    ]


    loadBalancingRules: [
      {
        name: ruleName

        properties: {

          protocol: 'Tcp'

          frontendPort: 80

          backendPort: 80


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


          enableFloatingIP: false

          idleTimeoutInMinutes: 4

          disableOutboundSnat: true
        }
      }
    ]
  }
}


output loadBalancerName string = ilb.name

output backendPoolId string = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  lbName,
  backendPoolName
)
