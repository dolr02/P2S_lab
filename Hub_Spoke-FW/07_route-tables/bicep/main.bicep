param location string
param firewallPrivateIp string

param spoke1VnetName string
param spoke2VnetName string

param spoke1SubnetName string
param spoke2SubnetName string

resource rtSpoke1 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-spoke1-to-fw'
  location: location

  properties: {
    routes: [
      {
        name: 'to-spoke2-via-fw'
        properties: {
          addressPrefix: '10.2.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}

resource rtSpoke2 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-spoke2-to-fw'
  location: location

  properties: {
    routes: [
      {
        name: 'to-spoke1-via-fw'
        properties: {
          addressPrefix: '10.1.0.0/16'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}

resource spoke1SubnetUpdate 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${spoke1VnetName}/${spoke1SubnetName}'

  properties: {
    addressPrefix: '10.1.1.0/24'

    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'

    routeTable: {
      id: rtSpoke1.id
    }
  }
}

resource spoke2SubnetUpdate 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  name: '${spoke2VnetName}/${spoke2SubnetName}'

  properties: {
    addressPrefix: '10.2.1.0/24'

    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'

    routeTable: {
      id: rtSpoke2.id
    }
  }
}
