param sharedKey string

resource connection 'Microsoft.Network/connections@2023-09-01' = {
  name: 'conn-azure-onprem'
  location: resourceGroup().location
  properties: {
    virtualNetworkGateway1: {
      id: resourceId('Microsoft.Network/virtualNetworkGateways', 'vpngw-azure')
    }
    localNetworkGateway2: {
      id: resourceId('Microsoft.Network/localNetworkGateways', 'lng-onprem')
    }

    connectionType: 'IPsec'
    sharedKey: sharedKey

    enableBgp: false
    usePolicyBasedTrafficSelectors: false
    dpdTimeoutSeconds: 45
    ipsecPolicies: []
    trafficSelectorPolicies: []
    connectionMode: 'Default'
    ikeProtocol: 'IKEv2'
  }
}
