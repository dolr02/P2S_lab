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

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'vnet-dev-eus-01'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: 'snet-dev-eus-web'
  parent: vnet
  properties: {
    addressPrefix: '10.0.1.0/24'
    natGateway: {
      id: natGateway.id
    }
  }
}
