// ======================================================
// Azure Firewall Deployment
// ======================================================

param firewallName string
param hubVnetName string
param firewallSubnetName string
param location string

resource firewallPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: '${firewallName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2023-09-01' = {
  name: firewallName
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    ipConfigurations: [
      {
        name: 'fw-ipconfig'
        properties: {
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              hubVnetName,
              firewallSubnetName
            )
          }
          publicIPAddress: {
            id: firewallPip.id
          }
        }
      }
    ]
  }
}

output firewallName string = firewall.name
output firewallPublicIp string = firewallPip.properties.ipAddress
output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
