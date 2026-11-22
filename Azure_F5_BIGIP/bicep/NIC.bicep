param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: 'vnet-f5-lab'
}

var interfaces = [
  { role: 'mgmt', ipForwarding: false }
  { role: 'external', ipForwarding: true }
  { role: 'internal', ipForwarding: true }
]

var externalVipConfig = [
  {
    name: 'ipconfig-vip'
    properties: {
      primary: false
      privateIPAllocationMethod: 'Static'
      privateIPAddress: '10.73.1.10'
      subnet: {
        id: '${vnet.id}/subnets/snet-f5-external'
      }
    }
  }
]

resource nics 'Microsoft.Network/networkInterfaces@2024-05-01' = [for nic in interfaces: {
  name: 'nic-f5-${nic.role}'
  location: location
  properties: {
    enableIPForwarding: nic.ipForwarding
    ipConfigurations: concat([
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnet.id}/subnets/snet-f5-${nic.role}'
          }
        }
      }
    ], nic.role == 'external' ? externalVipConfig : [])
  }
}]
