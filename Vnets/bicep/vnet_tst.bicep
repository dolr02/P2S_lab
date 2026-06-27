resource vnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: 'vnet-tst-eus-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-tst-eus-01'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output appSubnetName string = 'snet-tst-eus-01'
ppSubnetName

