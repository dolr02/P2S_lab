param location string = resourceGroup().location
param vnetName string = 'vnet-dev-eus-01'
param gatewayName string = 'vpngw-dev-eus-01'
param publicIpName string = 'pip-vpn-gateway'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: 'GatewaySubnet'
}

resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' existing = {
  name: publicIpName
}

resource gw 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: gatewayName
  location: location
  sku: {
    name: 'VpnGw1AZ'
    tier: 'VpnGw1AZ'
  }
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    ipConfigurations: [
      {
        name: 'gw-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]
  }
}

output gatewayId string = gw.id
output gatewayPublicIp string = pip.properties.ipAddress
