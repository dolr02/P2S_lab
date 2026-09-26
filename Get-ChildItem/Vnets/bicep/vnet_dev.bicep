resource vnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: 'vnet-dev-eus-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-dev-eus-01'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.254.0/27'
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output appSubnetName string = 'snet-dev-eus-01'
