param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: 'vnet-f5-lab'
}

var interfaces = [
  { role: 'mgmt', ipForwarding: false }
  { role: 'external', ipForwarding: true }
  { role: 'internal', ipForwarding: true }
]

resource nics 'Microsoft.Network/networkInterfaces@2024-05-01' = [for nic in interfaces: {
  name: 'nic-f5-${nic.role}'
  location: location
  properties: {
    enableIPForwarding: nic.ipForwarding
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/snet-f5-${nic.role}'
          }
        }
      }
    ]
  }
}]
