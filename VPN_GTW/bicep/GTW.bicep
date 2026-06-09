param location string = resourceGroup().location

// VNET + SUBNET
param vnetName string = 'vnet-dev-eus-01'
param gatewaySubnetName string = 'GatewaySubnet'

// CERTIFIKÁT (root cert)
param rootCertName string = 'P2SRootCert'
param rootCertData string

// P2S address pool
param p2sPool string = '172.16.0.0/24'

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

// Reference to existing Gateway subnet
resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: gatewaySubnetName
}

// VPN Gateway
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
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          p2sPool
        ]
      }
      vpnClientRootCertificates: [
        {
          name: rootCertName
          properties: {
            publicCertData: rootCertData
          }
        }
      ]
      vpnClientProtocols: [
        'OpenVPN'
        'IKEv2'
      ]
    }
  }
}
