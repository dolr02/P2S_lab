// ======================================================
// Azure Firewall Deployment
// File: firewall.bicep
// Resource Group: rg-p2s-lab
// ======================================================

param firewallName string = 'fw-hub-eus-01'
param hubVnetName string = 'vnet-hub-eus-01'
param firewallSubnetName string = 'AzureFirewallSubnet'
param location string = resourceGroup().location

// ------------------------------------------------------
// PUBLIC IP FOR FIREWALL
// ------------------------------------------------------
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

// ------------------------------------------------------
// FIREWALL
// ------------------------------------------------------
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

// ------------------------------------------------------
// OUTPUTS
// ------------------------------------------------------
output firewallName string = firewall.name
output firewallPublicIp string = firewallPip.properties.ipAddress
output firewallPrivateIp string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
