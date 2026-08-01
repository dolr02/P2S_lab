// AGW.bicep
param location string = resourceGroup().location
param vnetResourceGroup string = resourceGroup().name
param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'
param appGwName string = 'p2slab-appgw'
param existingPublicIpId string = ''
param skuCapacity int = 2
@allowed(['Prevention','Detection'])
param wafMode string = 'Prevention'
param backendTargets array
param tags object = {}

resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  parent: vnet
  name: subnetName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2022-09-01' = if (empty(existingPublicIpId)) {
  name: '${appGwName}-pip'
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
  tags: tags
}

var frontendPublicIpId = empty(existingPublicIpId) ? publicIp.id : existingPublicIpId

resource appGw 'Microsoft.Network/applicationGateways@2022-05-01' = {
  name: appGwName
  location: location
  sku: {
    name: 'WAF_v2'
    tier: 'WAF_v2'
    capacity: skuCapacity
  }
  properties: {
    gatewayIPConfigurations: [
      {
        name: 'appGwIpConfig'
        properties: { subnet: { id: subnet.id } }
      }
    ]
    frontendIPConfigurations: [
      { name: 'appGwFrontendIP'; properties: { publicIPAddress: { id: frontendPublicIpId } } }
    ]
    frontendPorts: [
      { name: 'httpPort'; properties: { port: 80 } }
      { name: 'httpsPort'; properties: { port: 443 } }
    ]
    backendAddressPools: [
      { name: 'backendPool'; properties: { backendAddresses: [] } }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'httpSettings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    probes: [
      {
        name: 'healthProbe'
        properties: {
          protocol: 'Http'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
        }
      }
    ]
    httpListeners: [
      {
        name: 'httpListener'
        properties: {
          frontendIPConfiguration: { id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGw.name, 'appGwFrontendIP') }
          frontendPort: { id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGw.name, 'httpPort') }
          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: { id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGw.name, 'httpListener') }
          backendAddressPool: { id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGw.name, 'backendPool') }
          backendHttpSettings: { id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGw.name, 'httpSettings') }
        }
      }
