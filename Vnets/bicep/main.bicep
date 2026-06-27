resource devVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-dev-eus-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-dev-eus-01'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource tstVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-tst-eus-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-tst-eus-01'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}



