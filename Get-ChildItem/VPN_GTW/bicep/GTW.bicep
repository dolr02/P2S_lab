param devVnetName string = 'vnet-dev-eus-01'
param devResourceGroup string = 'rg-p2s-lab'
param location string = resourceGroup().location

// EXISTUJÍCÍ VNET
resource devVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: devVnetName
  scope: resourceGroup(devResourceGroup)
}

// EXISTUJÍCÍ GatewaySubnet
resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: devVnet
  name: 'GatewaySubnet'
}

// EXISTUJÍCÍ Public IP
resource vpnPip 'Microsoft.Network/publicIPAddresses@2023-09-01' existing = {
  name: 'pip-vpn-gateway'
}

// VPN GATEWAY (správně)
resource vpnGw 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: 'vpngw-dev-eus-01'
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
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
  }
}


