targetScope = 'resourceGroup'

param location string = resourceGroup().location

var vnetName = 'vnet-consumer'
var subnetName = 'snet-vm'

var lbName = 'ilb-consumer'
var backendPoolName = 'consumer-backend-pool'

var consumerNics = [
  'pl-consumer-nic-1'
  'pl-consumer-nic-2'
  'pl-consumer-nic-3'
  'pl-consumer-nic-4'
  'pl-consumer-nic-5'
]


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}


resource lb 'Microsoft.Network/loadBalancers@2023-09-01' = {

  name: lbName
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {

    frontendIPConfigurations: [
      {
        name: 'frontend-ip'

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
        name: 'tcp-probe'

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
        name: 'http-rule'

        properties: {

          frontendIPConfiguration: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/frontendIPConfigurations',
              lbName,
              'frontend-ip'
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
              'tcp-probe'
            )
          }

          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80

          enableFloatingIP: false
          idleTimeoutInMinutes: 4
        }
      }
    ]
  }
}


// Existing NIC references

resource existingConsumerNics 'Microsoft.Network/networkInterfaces@2023-09-01' existing = [
  for nicName in consumerNics: {
    name: nicName
  }
]


// Attach NICs to ILB backend pool

resource nicBackendAssociation 'Microsoft.Network/networkInterfaces@2023-09-01' = [
  for i in range(0, length(consumerNics)): {

    name: consumerNics[i]
    location: location

    properties: {

      ipConfigurations: [
        {
          name: 'ipconfig1'

          properties: {

            loadBalancerBackendAddressPools: [
              {
                id: resourceId(
                  'Microsoft.Network/loadBalancers/backendAddressPools',
                  lbName,
                  backendPoolName
                )
              }
            ]
          }
        }
      ]
    }
  }
]


output loadBalancerName string = lb.name

output backendPool string = backendPoolName
