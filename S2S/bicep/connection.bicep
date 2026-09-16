param sharedKey string

resource connection 'Microsoft.Network/connections@2023-09-01' = {
  name: 'conn-azure-onprem'
  location: resourceGroup().location
  properties: {
    virtualNetworkGateway1: {
      id: resourceId('Microsoft.Network/virtualNetworkGateways', 'vpngw-azure')
      properties: {} // Bicep typ provider to vyžaduje
    }
    localNetworkGateway2: {
      id: resourceId('Microsoft.Network/localNetworkGateways', 'lng-onprem')
      properties: {} // Bicep typ provider to vyžaduje
    }

    connectionType: 'IPsec'
    sharedKey: sharedKey

    // IKEv2 – správná property podle API
    connectionProtocol: 'IKEv2'

    enableBgp: false
    usePolicyBasedTrafficSelectors: false
    dpdTimeoutSeconds: 45
    ipsecPolicies: []
    trafficSelectorPolicies: []
    connectionMode: 'Default'
  }
}
