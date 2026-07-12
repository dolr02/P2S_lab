@description('Name of Load Balancer')
param lbName string = 'lb-dev-eus-01'

@description('Public IP name')
param publicIpName string = 'pip-lb-dev-eus-01'

@description('Existing NIC names')
param nicDevName string = 'nic-dev-eus-01'
param nicTstName string = 'nic-tst-eus-01'

param location string = resourceGroup().location


// Existing NICs
resource nicDev 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: nicDevName
}

resource nicTst 'Microsoft.Network/networkInterfaces@2023-09-01' existing = {
  name: nicTstName
}


// Public IP for Load Balancer
resource publicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
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
          publicIPAddress: {
            id: publicIp.id
          }
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
        name: 'tcp-probe-80'

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
              'frontend-ip'
            )
          }

          backendAddressPool: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/backendAddressPools',
              lbName,
              'backend-pool'
            )
          }

          probe: {
            id: resourceId(
              'Microsoft.Network/loadBalancers/probes',
              lbName,
              'tcp-probe-80'
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
resource nicDevUpdate 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicDevName

  properties: {

    ipConfigurations: [
      {
        name: nicDev.properties.ipConfigurations[0].name

        properties: {

          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                lbName,
                'backend-pool'
              )
            }
          ]

          subnet: nicDev.properties.ipConfigurations[0].properties.subnet
          privateIPAddress: nicDev.properties.ipConfigurations[0].properties.privateIPAddress
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource nicTstUpdate 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: nicTstName

  properties: {

    ipConfigurations: [
      {
        name: nicTst.properties.ipConfigurations[0].name

        properties: {

          loadBalancerBackendAddressPools: [
            {
              id: resourceId(
                'Microsoft.Network/loadBalancers/backendAddressPools',
                lbName,
                'backend-pool'
              )
            }
          ]

          subnet: nicTst.properties.ipConfigurations[0].properties.subnet
          privateIPAddress: nicTst.properties.ipConfigurations[0].properties.privateIPAddress
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


output loadBalancerPublicIP string = publicIp.properties.ipAddress
