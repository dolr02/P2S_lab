@description('Name of the existing Storage Account')
param saName string

@description('Name of the existing Virtual Network')
param vnetName string = 'vnet-dev-eus-01'

@description('Name of the existing Subnet for Private Endpoint')
param subnetName string

@description('Location')
param location string = 'eastus'

@description('Resource Group of existing VNET')
param vnetRg string = 'rg-p2s-lab'

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: saName
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRg)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: subnetName
  parent: vnet
}

resource pe 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${saName}-pe-blob'
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'blob-connection'
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

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.blob.core.windows.net'
  scope: resourceGroup(vnetRg)
}

resource dnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${vnetName}-blob-link'
  parent: dnsZone
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

resource dnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '${saName}'
  parent: dnsZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: pe.properties.networkInterfaces[0].properties.ipConfigurations[0].properties.privateIPAddress
      }
    ]
  }
}
