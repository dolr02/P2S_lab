param location string = 'eastus'
param firewallPolicyName string = 'fw-policy-hub-eus-01'
param ruleCollectionGroupName string = 'rcg-hubspoke-01'

param vm1PrivateIp string = '10.1.1.4'
param vm2PrivateIp string = '10.2.1.4'

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-05-01' = {
  name: firewallPolicyName
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
    threatIntelMode: 'Alert'
  }
}

resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-05-01' = {
  parent: firewallPolicy
  name: ruleCollectionGroupName
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'rc-allow-https'
        priority: 100
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            name: 'allow-vm1-to-vm2-https'
            description: 'Allow HTTPS from Spoke 1 VM to Spoke 2 VM'
            ruleType: 'NetworkRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              vm1PrivateIp
            ]
            destinationAddresses: [
              vm2PrivateIp
            ]
            destinationPorts: [
              '443'
            ]
          }
          {
            name: 'allow-vm2-to-vm1-https'
            description: 'Allow HTTPS from Spoke 2 VM to Spoke 1 VM'
            ruleType: 'NetworkRule'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              vm2PrivateIp
            ]
            destinationAddresses: [
              vm1PrivateIp
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
      }
    ]
  }
}

output firewallPolicyId string = firewallPolicy.id
