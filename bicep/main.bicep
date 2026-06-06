module vnet './bicep/vnet.bicep' = {
  name: 'vnetModule'
  params: {
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    appSubnetName: vmSubnetName
    appSubnetPrefix: '10.1.0.0/24'
    gatewaySubnetPrefix: '10.1.255.0/27'
  }
}
