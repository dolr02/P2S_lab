//
// DEV parameters
//
param devVnetName string
param devVnetAddressPrefix string
param devAppSubnetName string
param devAppSubnetPrefix string
param devGatewaySubnetPrefix string

//
// TST parameters
//
param tstVnetName string
param tstVnetAddressPrefix string
param tstAppSubnetName string
param tstAppSubnetPrefix string

//
// DEV VNET (má GatewaySubnet)
//
module dev './vnet_dev.bicep' = {
  name: 'devVnet'
  params: {
    vnetName: devVnetName
    vnetAddressPrefix: devVnetAddressPrefix
    appSubnetName: devAppSubnetName
    appSubnetPrefix: devAppSubnetPrefix
    gatewaySubnetPrefix: devGatewaySubnetPrefix
  }
}

//
// TST VNET (bez GatewaySubnet)
//
module tst './vnet_tst.bicep' = {
  name: 'tstVnet'
  params: {
    vnetName: tstVnetName
    vnetAddressPrefix: tstVnetAddressPrefix
    appSubnetName: tstAppSubnetName
    appSubnetPrefix: tstAppSubnetPrefix
  }
}
