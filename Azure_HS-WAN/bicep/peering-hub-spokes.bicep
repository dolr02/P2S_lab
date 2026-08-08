// ======================================================
// Hub ↔ Spoke Peering
// File: peering-hub-spokes.bicep
// Resource Group: rg-p2s-lab
// ======================================================

param hubVnetName string = 'vnet-hub-eus-01'
param devVnetName string = 'vnet-dev-eus-01'
param tstVnetName string = 'vnet-tst-eus-01'
param location string = resourceGroup().location

// ------------------------------------------------------
// HUB → DEV
// ------------------------------------------------------
resource hubToDev 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${hubVnetName}/hub-to-dev'
  location: location
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', devVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
  }
}

// ------------------------------------------------------
// DEV → HUB
// ------------------------------------------------------
resource devToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${devVnetName}/dev-to-hub'
  location: location
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', hubVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
  }
}

// ------------------------------------------------------
// HUB → TST
// ------------------------------------------------------
resource hubToTst 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${hubVnetName}/hub-to-tst'
  location: location
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', tstVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
  }
}

// ------------------------------------------------------
// TST → HUB
// ------------------------------------------------------
resource tstToHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  name: '${tstVnetName}/tst-to-hub'
  location: location
  properties: {
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', hubVnetName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    useRemoteGateways: true
  }
}

// ------------------------------------------------------
// OUTPUTS
// ------------------------------------------------------
output hubToDevPeering string = hubToDev.name
output devToHubPeering string = devToHub.name
output hubToTstPeering string = hubToTst.name
output tstToHubPeering string = tstToHub.name
