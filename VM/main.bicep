param location string = resourceGroup().location
param adminUsername string = 'azureuser'
@secure()
param adminPassword string

//
// VNET
//
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'lab-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'app'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

//
// NIC DEV
//
resource nicDev 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-dev'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
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
  name: 'nic-tst'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
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
  name: 'vm-dev'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-dev'
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
  name: 'vm-tst'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-tst'
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
