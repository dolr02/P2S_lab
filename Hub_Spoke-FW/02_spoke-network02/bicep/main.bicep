param location string = resourceGroup().location

@description('Spoke2 Virtual Network name')
param spokeVnetName string = 'vnet-spoke2-eus-01'

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: spokeVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-workload'
        properties: {
          addressPrefix: '10.2.1.0/24'
        }
      }
    ]
  }
}

output spokeVnetId string = spokeVnet.id
