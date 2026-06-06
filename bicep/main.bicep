@description('Location for all networking resources')
param location string = resourceGroup().location

//
// DEV VNet (má GatewaySubnet)
//
module vnetDev './vnet-dev.bicep' = {
  name: 'vnetDev'
  params: {
    vnetName: 'vnet-dev-eus-01'
    vnetAddressPrefix: '10.0.0.0/16'
    appSubnetName: 'snet-dev-eus-web'
    appSubnetPrefix: '10.0.0.0/24'
    gatewaySubnetPrefix: '10.0.255.0/27'
  }
}

//
// TST VNet (bez GatewaySubnet)
//
module vnetTst './vnet-tst.bicep' = {
  name: 'vnetTst'
  params: {
    vnetName: 'vnet-tst-eus-01'
    vnetAddressPrefix: '10.1.0.0/16'
    appSubnetName: 'snet-tst-eus-app'
    appSubnetPrefix: '10.1.0.0/24'
  }
}

//
// Outputs
//
output devVnetId string = vnetDev.outputs.vnetId
output devAppSubnetId string = vnetDev.outputs.appSubnetId
output devGatewaySubnetId string = vnetDev.outputs.gatewaySubnetId

output tstVnetId string = vnetTst.outputs.vnetId
output tstAppSubnetId string = vnetTst.outputs.appSubnetId
