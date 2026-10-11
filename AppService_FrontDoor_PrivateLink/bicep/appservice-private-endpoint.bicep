targetScope = 'resourceGroup'

param location string = resourceGroup().location

@description('Name of the existing App Service')
param appServiceName string

@description('Name of the existing VNet')
param vnetName string

@description('Name of the existing subnet for Private Endpoints')
param subnetName string

@description('Name of the Private Endpoint to create')
param privateEndpointName string = '${appServiceName}-pe'

@description('Private DNS zone for App Service')
param privateDnsZoneName string = 'privatelink.azurewebsites.net'

// Existing App Service
resource appService 'Microsoft.Web/sites@2023-12-01' existing = {
  name: appServiceName
}

// Existing VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

// Existing subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  parent: vnet
  name: subnetName
}

// Private Endpoint to App Service
resource appServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${appServiceName}-sites-connection'
        properties: {
          privateLinkServiceId: appService.id
          groupIds: [
            'sites'
          ]
          requestMessage: 'Private Endpoint for App Service lab'
        }
      }
    ]
  }
}

// Existing or new Private DNS zone
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

// Link DNS zone to the existing VNet
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// Automatically create the DNS records for the PE
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  parent: appServicePrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'appservice-zone'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}

output privateEndpointId string = appServicePrivateEndpoint.id
output privateDnsZoneId string = privateDnsZone.id
output privateDnsZoneLinkId string = privateDnsZoneLink.id
