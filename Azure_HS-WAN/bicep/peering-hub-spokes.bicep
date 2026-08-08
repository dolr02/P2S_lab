param hubVnetName string = 'vnet-hub-eus-01'
param devVnetName string = 'vnet-dev-eus-01'
param tstVnetName string = 'vnet-tst-eus-01'

// HUB → DEV
resource hubToDev 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${hubVnetName}/hub-to-dev'
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', devVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

// DEV → HUB
resource devToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${devVnetName}/dev-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', hubVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

// HUB → TST
resource hubToTst 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${hubVnetName}/hub-to-tst'
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', tstVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

// TST → HUB
resource tstToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${tstVnetName}/tst-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', hubVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
  }
}

output hubToDevPeering string = hubToDev.name
output devToHubPeering string = devToHub.name
output hubToTstPeering string = hubToTst.name
output tstToHubPeering string = tstToHub.name
