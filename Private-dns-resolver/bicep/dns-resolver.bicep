param location string = resourceGroup().location

resource vnet2 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: 'vnet-2'
}

resource resolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: 'dnspr-p2s-lab'
  location: location
  properties: {
    virtualNetwork: {
      id: vnet2.id
    }
  }
}

output resolverName string = resolver.name
output resolverId string = resolver.id
