targetScope = 'resourceGroup'

param location string = resourceGroup().location

var vnetName = 'vnet-consumer'
var subnetName = 'snet-vm'

var lbName = 'ilb-consumer'
var backendPoolName = 'consumer-backend-pool'


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
        name: 'http-probe'

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
              'http-probe'
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


resource nic1 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: 'pl-consumer-nic-1'
}

resource nic2 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: 'pl-consumer-nic-2'
}

resource nic3 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: 'pl-consumer-nic-3'
}

resource nic4 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: 'pl-consumer-nic-4'
}

resource nic5 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: 'pl-consumer-nic-5'
}
