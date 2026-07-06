param location string = resourceGroup().location

param saName string
param vnetName string
param subnetName string


// EXISTING STORAGE ACCOUNT
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: saName
}


// EXISTING VNET
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}


// EXISTING PRIVATE ENDPOINT SUBNET
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: vnet
  name: subnetName
}


// PRIVATE ENDPOINT
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: '${saName}-pe'
  location: location

  properties: {
    subnet: {
      id: subnet.id
    }

    privateLinkServiceConnections: [
      {
        name: '${saName}-blob'

        properties: {
          privateLinkServiceId: storageAccount.id

          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}


// PRIVATE DNS ZONE
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
}


// VNET LINK
resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-link'

  parent: privateDnsZone

  location: 'global'

  properties: {
    virtualNetwork: {
      id: vnet.id
    }

    registrationEnabled: false
  }
}


// DNS ZONE GROUP
resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {

  name: 'default'

  parent: privateEndpoint

  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob'

        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
