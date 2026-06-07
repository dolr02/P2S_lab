param location string = 'eastus'
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

//
// DEV VNET
//
resource vnetDev 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-dev-eus-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-dev-eus-web'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.255.0/27'
        }
      }
    ]
  }
}

//
// TST VNET
//
resource vnetTst 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-tst-eus-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-tst-eus-app'
        properties: {
          addressPrefix: '10.1.1.0/24'
        }
      }
    ]
  }
}

//
// Public IP for VPN Gateway
//
resource gwPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-vpngw-eus-01'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//
// VPN Gateway
//
resource vpngw 'Microsoft.Network/virtualNetworkGateways@2023-09-01' = {
  name: 'vpngw-dev-eus-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'gwipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${vnetDev.id}/subnets/GatewaySubnet'
          }
          publicIPAddress: {
            id: gwPip.id
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: [
          '172.16.0.0/24'
        ]
      }
    }
  }
}

//
// NIC DEV
//
resource nicDev 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-dev-eus-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnetDev.id}/subnets/snet-dev-eus-web'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

//
// NIC TST
//
resource nicTst 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-tst-eus-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnetTst.id}/subnets/snet-tst-eus-app'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

//
// VM DEV
//
resource vmDev 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-dev-eus-01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-dev-eus-01'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicDev.id
        }
      ]
    }
  }
}

//
// VM TST
//
resource vmTst 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-tst-eus-01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-tst-eus-01'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicTst.id
        }
      ]
    }
  }
}
