param location string = resourceGroup().location

param saName string
param vnetName string
param subnetName string

// EXISTING STORAGE ACCOUNT
resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: saName
}

// EXISTING VNET
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

// EXISTING SUBNET (must be PE enabled)
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: subnetName
  parent: vnet
}

// PRIVATE ENDPOINT
resource pe 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${saName}-pe'
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${saName}-blob-conn'
        properties: {
          privateLinkServiceId: sa.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// PRIVATE DNS ZONE (NO A RECORDS!)
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

// LINK DNS ZONE TO VNET
resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-dns-link'
  parent: dnsZone
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

// DNS ZONE GROUP (THIS CREATES A RECORD AUTOMATICALLY)
resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: 'default'
  parent: pe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob-config'
        properties: {
          privateDnsZoneId: dnsZone.id
        }
      }
    ]
  }
}
