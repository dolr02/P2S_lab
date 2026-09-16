param vnetName string = 'vnet-dev-eus-01'
param gatewayName string = 'vpngw-azure'
param publicIpName string = 'vpngw-azure-pip'

//
// 1) GatewaySubnet
//
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: 'GatewaySubnet'
  parent: vnet
  properties: {
    addressPrefix: '10.0.255.0/27'
  }
}

//
// 2) Public IP for VPN Gateway
//
resource pip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIpName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//
// 3) Azure VPN Gateway
//
resource gw 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: gatewayName
  location: resourceGroup().location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
  sku: {
  name: 'VpnGw1AZ'
  tier: 'VpnGw1AZ'
}
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
