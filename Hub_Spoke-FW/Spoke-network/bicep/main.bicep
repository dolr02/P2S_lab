param location string = resourceGroup().location

@description('Spoke1 Virtual Network name')
param spokeVnetName string = 'vnet-spoke1-eus-01'

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-workload'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

output spokeVnetId string = spokeVnet.id
