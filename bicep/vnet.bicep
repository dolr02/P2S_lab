@description('Name of the Virtual Network')
param vnetName string = 'vnet-dev-eus-01'

@description('Address space for the VNet')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Web subnet name')
param webSubnetName string = 'snet-dev-eus-web'

@description('Web subnet prefix')
param webSubnetPrefix string = '10.0.0.0/24'

@description('App subnet name')
param appSubnetName string = 'snet-dev-eus-app'

@description('App subnet prefix')
param appSubnetPrefix string = '10.1.0.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: webSubnetPrefix
        }
      }
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output webSubnetId string = vnet.properties.subnets[0].id
output appSubnetId string = vnet.properties.subnets[1].id
