param devVnetName string
param devVnetAddressPrefix string
param devAppSubnetName string
param devAppSubnetPrefix string
param devGatewaySubnetPrefix string

param tstVnetName string
param tstVnetAddressPrefix string
param tstAppSubnetName string
param tstAppSubnetPrefix string

module dev './vnet-dev.bicep' = {
  name: 'devVnet'
  params: {
    vnetName: devVnetName
    vnetAddressPrefix: devVnetAddressPrefix
    appSubnetName: devAppSubnetName
    appSubnetPrefix: devAppSubnetPrefix
    gatewaySubnetPrefix: devGatewaySubnetPrefix
  }
}

module tst './vnet-tst.bicep' = {
  name: 'tstVnet'
  params: {
    vnetName: tstVnetName
    vnetAddressPrefix: tstVnetAddressPrefix
    appSubnetName: tstAppSubnetName
    appSubnetPrefix: tstAppSubnetPrefix
  }
}
