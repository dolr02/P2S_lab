resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: 'vpngw-dev-eus-01'
  location: resourceGroup().location
  properties: {
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    ipConfigurations: [
      {
        name: 'gwipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
          subnet: {
            id: gatewaySubnet.id
          }
        }
      }
    ]
    vpnClientConfiguration: {
      vpnClientProtocols: [
        'OpenVPN'
      ]
      vpnClientRootCertificates: [
        {
          name: 'P2SRootCert'
          properties: {
            publicCertData: rootCertData
          }
        }
      ]
    }
  }
}
