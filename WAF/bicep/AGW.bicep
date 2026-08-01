// AGW_param.bicep
@description('Deployment location')
param location string = 'westeurope'

@description('Resource group where the existing VNet lives')
param vnetResourceGroup string = 'rg-p2s-lab'

@description('Existing virtual network name')
param vnetName string = 'vnet-dev-eus-01'

@description('Existing subnet name for AppGW')
param subnetName string = 'snet-dev-eus-01'

@description('Application Gateway name')
param appGwName string = 'dev-appgw'

@description('Existing Public IP resourceId to use for frontend. Leave empty to create new.')
param existingPublicIpId string = ''

@description('AppGW SKU capacity')
param skuCapacity int = 2

@allowed(['Prevention','Detection'])
@description('WAF mode')
param wafMode string = 'Prevention'

@description('Backend targets: array of IP addresses or NIC resourceIds')
param backendTargets array = [
  '10.0.1.4'
  '10.0.1.5'
]

@description('Optional tags')
param tags object = {
  env: 'dev'
  lab: 'P2S_lab'
}

module appgw './AGW.bicep' = {
  name: 'deployAppGwFromParams'
  params: {
    location: location
    vnetResourceGroup: vnetResourceGroup
    vnetName: vnetName
    subnetName: subnetName
    appGwName: appGwName
    existingPublicIpId: existingPublicIpId
    skuCapacity: skuCapacity
    wafMode: wafMode
    backendTargets: backendTargets
    tags: tags
  }
}

output appGwId string = appgw.outputs.appGwId
output frontendPublicIp string = appgw.outputs.frontendPublicIp
