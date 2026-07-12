@description('Public IP for NAT Gateway')
resource natPip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-nat-dev'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

@description('NAT Gateway')
resource natGateway 'Microsoft.Network/natGateways@2023-05-01' = {
  name: 'ngw-dev'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 10
    publicIpAddresses: [
      {
        id: natPip.id
      }
    ]
  }
}

@description('Existing VNET')
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'vnet-dev-eus-01'
}

@description('Existing subnet')
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  parent: vnet
  name: 'snet-dev-eus-01'
}

@description('Associate NAT Gateway with subnet')
resource subnetNatAssociation 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: 'snet-dev-eus-01'
  properties: {
    addressPrefix: subnet.properties.addressPrefix
    natGateway: {
      id: natGateway.id
    }
    privateEndpointNetworkPolicies: subnet.properties.privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: subnet.properties.privateLinkServiceNetworkPolicies
  }
}
