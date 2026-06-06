@description('Name of the Virtual Network')
param vnetName string

@description('Address space for the VNet')
param vnetAddressPrefix string

@description('App subnet name')
param appSubnetName string

@description('App subnet prefix')
param appSubnetPrefix string

@description('Create GatewaySubnet?')
param createGatewaySubnet bool = false

@description('GatewaySubnet prefix (only used if createGatewaySubnet = true)')
param gatewaySubnetPrefix string = '10.0.255.0/27'

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
      if (createGatewaySubnet) {
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

output gatewaySubnetId string = createGatewaySubnet ?
  resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'GatewaySubnet') :
  ''
