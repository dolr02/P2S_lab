param location string = resourceGroup().location

// názvy můžeš změnit, ale nechávám je jednoduché
param vwanName string = 'p2s-vwan'
param vhubName string = 'p2s-vhub'

// ID Hub VNetu, který se připojí do Virtual Hubu
param hubVnetId string

resource vwan 'Microsoft.Network/virtualWans@2023-09-01' = {
  name: vwanName
  location: location
  properties: {
    type: 'Standard'
    disableVpnEncryption: false
  }
}

resource vhub 'Microsoft.Network/virtualHubs@2023-09-01' = {
  name: vhubName
  location: location
  properties: {
    addressPrefix: '10.200.0.0/24'
    virtualWan: {
      id: vwan.id
    }
  }
}

resource hubConnection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-09-01' = {
  name: '${vhub.name}/hub-to-hubvnet'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnetId
    }
    allowHubToRemoteVnetTransit: true
    allowRemoteVnetToUseHubVnetGateways: true
    enableInternetSecurity: false
  }
}
