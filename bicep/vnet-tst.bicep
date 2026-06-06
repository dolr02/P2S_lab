param vnetName string
param vnetAddressPrefix string
param appSubnetName string
param appSubnetPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2025-01-01' = {
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
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output appSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, appSubnetName)
