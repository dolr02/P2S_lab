param location string = resourceGroup().location
param azureVnetName string = 'vnet-dev-eus-01'
param onpremVnetName string = 'vnet-onprem-eus-01'

resource azureVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: azureVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [
      { name: 'snet-azure-vm', properties: { addressPrefix: '10.0.0.0/24' } }
      { name: 'GatewaySubnet', properties: { addressPrefix: '10.0.255.0/27' } }
    ]
  }
}

resource onpremVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: onpremVnetName
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['192.168.1.0/24'] }
    subnets: [
      { name: 'snet-onprem', properties: { addressPrefix: '192.168.1.0/24' } }
    ]
  }
}
