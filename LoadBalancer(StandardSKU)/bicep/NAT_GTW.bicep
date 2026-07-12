// Public IP for NAT Gateway
resource natPip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-nat-dev'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// NAT Gateway itself
resource natGateway 'Microsoft.Network/natGateways@2023-05-01' = {
  name: 'ngw-dev'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIpAddresses: [
      {
        id: natPip.id
      }
    ]
  }
}

// EXISTING VNET — THIS ONE EXISTS IN YOUR RG
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'vnet-dev-eus-01'
}

// EXISTING SUBNET — THIS ONE EXISTS IN YOUR VNET
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' existing = {
  name: 'snet-dev-eus-web'
  parent: vnet
}

// UPDATE SUBNET TO USE NAT GATEWAY
resource subnetUpdate 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: subnet.name
  parent: vnet
  properties: {
    addressPrefix: subnet.properties.addressPrefix
    natGateway: {
      id: natGateway.id
    }
  }
}
