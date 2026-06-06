@description('Location')
param location string = resourceGroup().location

@description('VNet name')
param vnetName string = 'vnet-dev-eus-01'

@description('VNet prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet name')
param appSubnetName string = 'snet-dev-eus-web'

@description('Subnet prefix')
param appSubnetPrefix string = '10.0.0.0/24'

@description('Gateway subnet prefix')
param gatewaySubnetPrefix string = '10.0.255.0/27'

module vnet './vnet.bicep' = {
  name: 'vnetModule'
  params: {
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    appSubnetName: appSubnetName
    appSubnetPrefix: appSubnetPrefix
    gatewaySubnetPrefix: gatewaySubnetPrefix
  }
}

output vnetId string = vnet.outputs.vnetId
output appSubnetId string = vnet.outputs.appSubnetId
output gatewaySubnetId string = vnet.outputs.gatewaySubnetId

