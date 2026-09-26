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


// EXISTING PE SUBNET
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
        name: '${saName}-blob-connection'

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
