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

// EXISTING SUBNET
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: subnetName
  parent: vnet
}

// PRIVATE ENDPOINT
resource pe 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${sa.name}-pe'
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${sa.name}-blob-conn'
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

// PRIVATE DNS ZONE
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

// LINK VNET -> DNS ZONE
resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnet.name}-dns-link'
  parent: dnsZone
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

// DNS ZONE GROUP (AUTO A RECORD)
resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: 'default'
  parent: pe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob-dns'
        properties: {
          privateDnsZoneId: dnsZone.id
        }
      }
    ]
  }
}
