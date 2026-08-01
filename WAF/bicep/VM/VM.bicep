param location string = resourceGroup().location

// EXISTUJÍCÍ NIC Z VM
resource nicImage 'Microsoft.Network/networkInterfaces@2022-09-01' existing = {
  name: 'nic-image'
}

resource nicVideo 'Microsoft.Network/networkInterfaces@2022-09-01' existing = {
  name: 'nic-video'
}

// EXISTUJÍCÍ VNET + SUBNET PRO AGW
resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: 'vnet-dev-eus-01'
}

resource snetAppGw 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' existing = {
  name: 'snet-dev-eus-01'
  scope: vnet
}

// PUBLIC IP PRO AGW
resource pip 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: 'p2slab-appgw-pip'
  location: location
  sku: { name: 'Standard' }
  properties: { publicIPAllocationMethod: 'Static' }
}

// WAF POLICY
resource wafPolicy 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2022-09-01' = {
  name: 'p2slab-waf-policy'
  location: location
  properties: {
    policySettings: { enabledState: 'Enabled', mode: 'Prevention' }
    managedRules: { managedRuleSets: [ { ruleSetType: 'OWASP', ruleSetVersion: '3.2' } ] }
  }
}

// APPLICATION GATEWAY
resource appGw 'Microsoft.Network/applicationGateways@2022-09-01' = {
  name: 'p2slab-appgw'
  location: location
  sku: { name: 'WAF_v2', tier: 'WAF_v2' }

  properties: {
    gatewayIPConfigurations: [
      {
        name: 'gw-ip'
        properties: { subnet: { id: snetAppGw.id } }
      }
    ]

    frontendIPConfigurations: [
      {
        name: 'frontend-ip'
        properties: { publicIPAddress: { id: pip.id } }
      }
    ]

    frontendPorts: [
      {
        name: 'port-80'
        properties: { port: 80 }
      }
    ]

    backendAddressPools: [
      {
        name: 'pool-image'
        properties: {
          backendIPConfigurations: [
            { id: nicImage.properties.ipConfigurations[0].id }
          ]
        }
      },
      {
        name: 'pool-video'
        properties: {
          backendIPConfigurations: [
            { id: nicVideo.properties.ipConfigurations[0].id }
          ]
        }
      }
    ]

    backendHttpSettingsCollection: [
      {
        name: 'http'
        properties: { port: 80, protocol: 'Http', requestTimeout: 30 }
      }
    ]

    httpListeners: [
      {
        name: 'listener-image'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGw.name, 'frontend-ip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGw.name, 'port-80')
          }
          protocol: 'Http'
        }
      },
      {
        name: 'listener-video'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGw.name, 'frontend-ip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGw.name, 'port-80')
          }
          protocol: 'Http'
        }
      }
    ]

    requestRoutingRules: [
      {
        name: 'rule-image'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGw.name, 'listener-image')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGw.name, 'pool-image')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGw.name, 'http')
          }
        }
      },
      {
        name: 'rule-video'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGw.name, 'listener-video')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGw.name, 'pool-video')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGw.name, 'http')
          }
        }
      }
    ]

    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      policy: { id: wafPolicy.id }
    }
  }
}
