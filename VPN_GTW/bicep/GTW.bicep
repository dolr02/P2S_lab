param devVnetName string = 'vnet-dev-eus-01'
param devResourceGroup string = 'rg-p2s-lab'

resource devVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: devVnetName
  scope: resourceGroup(devResourceGroup)
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: devVnet
  name: 'GatewaySubnet'
}

resource vpnGw 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: 'vpngw-dev-eus-01'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'gw-ipconfig'
        properties: {
          publicIPAddress: {
            id: vpnPip.id
          }
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
  }
}


