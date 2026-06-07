param devVnetName string
param devVnetAddressPrefix string

param tstVnetName string
param tstVnetAddressPrefix string

module devVnet './vnet-dev.bicep' = {
  name: 'devVnet'
  params: {
    vnetName: devVnetName
    addressPrefix: devVnetAddressPrefix
  }
}

module tstVnet './vnet-tst.bicep' = {
  name: 'tstVnet'
  params: {
    vnetName: tstVnetName
    addressPrefix: tstVnetAddressPrefix
  }
}
