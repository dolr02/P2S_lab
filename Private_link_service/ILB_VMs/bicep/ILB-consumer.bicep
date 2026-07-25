targetScope = 'resourceGroup'

param location string = resourceGroup().location

var lbName = 'ilb-consumer'
var backendPoolName = 'consumer-backend-pool'

var nicNames = [
  'pl-consumer-nic-1'
  'pl-consumer-nic-2'
  'pl-consumer-nic-3'
  'pl-consumer-nic-4'
  'pl-consumer-nic-5'
]


resource lb 'Microsoft.Network/loadBalancers@2023-09-01' existing = {
  name: lbName
}


resource backendPool 'Microsoft.Network/loadBalancers/backendAddressPools@2023-09-01' existing = {
  parent: lb
  name: backendPoolName
}


resource nics 'Microsoft.Network/networkInterfaces@2023-09-01' existing = [
  for nicName in nicNames: {
    name: nicName
  }
]


resource nicUpdate 'Microsoft.Network/networkInterfaces@2023-09-01' = [
  for (nicName, index) in nicNames: {
    name: nicName
    location: location

    properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'

          properties: {
            privateIPAddress: nics[index].properties.ipConfigurations[0].properties.privateIPAddress
            privateIPAllocationMethod: nics[index].properties.ipConfigurations[0].properties.privateIPAllocationMethod
            subnet: {
              id: nics[index].properties.ipConfigurations[0].properties.subnet.id
            }

            loadBalancerBackendAddressPools: [
              {
                id: backendPool.id
              }
            ]
          }
        }
      ]
    }
  }
]

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
