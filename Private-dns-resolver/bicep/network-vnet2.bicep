param location string = resourceGroup().location

resource vnet2 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-2'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }

    subnets: [
      {
        name: 'snet-dns-resolver'
        properties: {
          addressPrefix: '10.20.0.0/28'
          delegations: [
            {
              name: 'dns-resolver-delegation'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'snet-private-endpoints'
        properties: {
          addressPrefix: '10.20.1.0/24'
        }
      }
    ]
  }
}

output vnetName string = vnet2.name
output resolverSubnetPrefix string = '10.20.0.0/28'
output privateEndpointSubnetPrefix string = '10.20.1.0/24'
