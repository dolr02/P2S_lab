param location string = resourceGroup().location

param vnetName string = 'vnet-dev-eus-01'
param peSubnetName string = 'snet-pe'
param addressPrefix string = '10.10.2.0/24'

param storageAccountName string = 'stp2slab1376'

/*
  VNET (existing)
*/
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

/*
  PE SUBNET (must be dedicated)
*/
resource peSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  name: peSubnetName
  parent: vnet
  properties: {
    addressPrefix: addressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

/*
  STORAGE ACCOUNT
*/
resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
  }
}

/*
  PRIVATE ENDPOINT (Blob)
*/
resource pe 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${storageAccountName}-pe'
  location: location
  properties: {
    subnet: {
      id: peSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${storageAccountName}-blob-conn'
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

/*
  PRIVATE DNS ZONE
*/
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}

/*
  DNS ZONE LINK to VNET
*/
resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-link'
  parent: dnsZone
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

/*
  DNS A RECORD for PE
*/
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
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
