targetScope = 'resourceGroup'

var location = 'eastus'
var fwPrivateIp = '10.2.1.4'

// =========================
// Existing VNets
// =========================

resource devVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'vnet-dev-eus-01'
}

resource tstVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: 'vnet-tst-eus-01'
}

// =========================
// DEV Route Table
// =========================

resource rtDev 'Microsoft.Network/routeTables@2023-05-01' = {
  name: 'rt-dev'
  location: location

  properties: {
    disableBgpRoutePropagation: false

    routes: [
      {
        name: 'default-to-fw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwPrivateIp
        }
      }
    ]
  }
}

// =========================
// TST Route Table
// =========================

resource rtTst 'Microsoft.Network/routeTables@2023-05-01' = {
  name: 'rt-tst'
  location: location

  properties: {
    disableBgpRoutePropagation: false

    routes: [
      {
        name: 'default-to-fw'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: fwPrivateIp
        }
      }
    ]
  }
}

// =========================
// DEV subnet
// =========================

resource devSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: 'snet-dev-eus-01'
  parent: devVnet

  properties: {
    addressPrefix: '10.0.1.0/24'
    routeTable: {
      id: rtDev.id
    }
  }
}

// =========================
// TST subnet
// =========================

resource tstSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: 'snet-tst-eus-01'
  parent: tstVnet

  properties: {
    addressPrefix: '10.1.1.0/24'
    routeTable: {
      id: rtTst.id
    }
  }
}
