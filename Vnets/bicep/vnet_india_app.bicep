param location string = 'Central India'

param vnetName string = 'vnet-afd-pl-india-01'
param vnetAddressPrefix string = '10.20.0.0/16'

param appSubnetName string = 'snet-app-01'
param appSubnetPrefix string = '10.20.1.0/24'

param privateEndpointSubnetName string = 'snet-private-endpoints'
param privateEndpointSubnetPrefix string = '10.20.2.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetPrefix
      }
      }
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output appSubnetName string = appSubnetName
output privateEndpointSubnetName string = privateEndpointSubnetName
output privateEndpointSubnetId string = vnet.properties.subnets[1].id
