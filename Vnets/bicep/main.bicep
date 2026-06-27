resource devVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-dev'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-dev'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource tstVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-tst'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-tst'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}



