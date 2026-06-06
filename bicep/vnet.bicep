param vnetName string
param vnetAddressPrefix string
param appSubnetName string
param appSubnetPrefix string
param gatewaySubnetPrefix string

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
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: gatewaySubnetPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id

output appSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  appSubnetName
)

output gatewaySubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'GatewaySubnet'
)

