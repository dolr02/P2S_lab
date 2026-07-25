targetScope = 'resourceGroup'

param location string = resourceGroup().location

var vnetName = 'vnet-consumer'
var subnetName = 'snet-vm'

var lbName = 'ilb-consumer'
var frontendName = 'frontend-ip'
var backendPoolName = 'consumer-backend-pool'


// Existing VNET
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}


// Existing subnet where consumer VMs live
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}


// Existing VM NICs
var consumerNics = [
  'pl-consumer-nic-1'
  'pl-consumer-nic-2'
  'pl-consumer-nic-3'
  'pl-consumer-nic-4'
  'pl-consumer-nic-5'
]


resource nic1 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: consumerNics[0]
}

resource nic2 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: consumerNics[1]
}

resource nic3 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: consumerNics[2]
}

resource nic4 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: consumerNics[3]
}

resource nic5 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: consumerNics[4]
}


// Internal Load Balancer
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

          privateIPAddress: '10.1.2.20'
          privateIPAllocationMethod: 'Static'

          subnet: {
            id: subnet.id
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
        name: 'http-probe'

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
        name: 'http-rule'

        properties: {

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


// Attach NICs to backend pool
resource nic1Pool 'Microsoft.Network/networkInterfaces/ipConfigurations@2023-09-01' = {
  parent: nic1
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


resource nic2Pool 'Microsoft.Network/networkInterfaces/ipConfigurations@2023-09-01' = {
  parent: nic2
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


resource nic3Pool 'Microsoft.Network/networkInterfaces/ipConfigurations@2023-09-01' = {
  parent: nic3
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


resource nic4Pool 'Microsoft.Network/networkInterfaces/ipConfigurations@2023-09-01' = {
  parent: nic4
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


resource nic5Pool 'Microsoft.Network/networkInterfaces/ipConfigurations@2023-09-01' = {
  parent: nic5
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
