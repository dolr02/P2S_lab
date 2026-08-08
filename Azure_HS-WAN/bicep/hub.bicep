// ======================================================
// Hub VNet Deployment
// File: hub.bicep
// Resource Group: rg-p2s-lab
// ======================================================

param hubVnetName string = 'vnet-hub-eus-01'
param location string = resourceGroup().location

// Hub address space (confirmed)
param hubAddressPrefix string = '10.2.0.0/16'

// Subnets inside Hub
param firewallSubnetPrefix string = '10.2.1.0/24'
param sharedSubnetPrefix string = '10.2.2.0/24'

// ------------------------------------------------------
// HUB VNET
// ------------------------------------------------------
resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: firewallSubnetPrefix
        }
      }
      {
        name: 'SharedServicesSubnet'
        properties: {
          addressPrefix: sharedSubnetPrefix
        }
      }
    ]
  }
}

// ------------------------------------------------------
// Outputs
// ------------------------------------------------------
output hubVnetName string = hubVnet.name
output firewallSubnetName string = 'AzureFirewallSubnet'
output sharedSubnetName string = 'SharedServicesSubnet'
