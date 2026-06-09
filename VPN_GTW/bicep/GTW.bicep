param location string = resourceGroup().location
param vnetName string = 'vnet-dev-eus-01'
param gatewaySubnetName string = 'GatewaySubnet'

// Public IP pro VPN Gateway
resource vpnPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-vpn-gateway'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// VNET reference
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

// GatewaySubnet reference
resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: gatewaySubnetName
}

// ČISTÁ VPN GATEWAY BEZ P2S
resource vpnGw 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: 'vpngw-dev-eus-01'
  location: location
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
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
}

