// DEV params
param devVnetName string = 'vnet-dev-eus-01'
param devVnetAddressPrefix string = '10.0.0.0/16'
param devAppSubnetName string = 'snet-dev-eus-01'
param devAppSubnetPrefix string = '10.0.1.0/24'
param devGatewaySubnetPrefix string = '10.0.254.0/27'

// TST params
param tstVnetName string = 'vnet-tst-eus-01'
param tstVnetAddressPrefix string = '10.1.0.0/16'
param tstAppSubnetName string = 'snet-tst-eus-01'
param tstAppSubnetPrefix string = '10.1.1.0/24'

// DEV VNET
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

// TST VNET
module tst './vnet_tst.bicep' = {
  name: 'tstVnet'
  params: {
    vnetName: tstVnetName
    vnetAddressPrefix: tstVnetAddressPrefix
    appSubnetName: tstAppSubnetName
    appSubnetPrefix: tstAppSubnetPrefix
  }
}
