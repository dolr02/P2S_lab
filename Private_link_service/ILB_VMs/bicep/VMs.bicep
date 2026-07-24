var location = 'eastus'

var subnetId = '/subscriptions/a48d08c6-0e09-428b-a68f-ae160e9abf86/resourceGroups/rg-consumer-dev-eus/providers/Microsoft.Network/virtualNetworks/vnet-consumer/subnets/snet-vm'


resource nic01 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-consumer-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.2.4'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource nic02 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-consumer-02'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.2.5'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource nic03 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-consumer-03'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.2.6'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource nic04 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-consumer-04'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.2.7'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}


resource vm01 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-consumer-01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'vm-consumer-01'
      adminUsername: 'azureuser'
      adminPassword: 'Azure12345!Password'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic01.id
        }
      ]
    }
  }
}


resource vm02 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-consumer-02'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'vm-consumer-02'
      adminUsername: 'azureuser'
      adminPassword: 'Azure12345!Password'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic02.id
        }
      ]
    }
  }
}


resource vm03 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-consumer-03'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'vm-consumer-03'
      adminUsername: 'azureuser'
      adminPassword: 'Azure12345!Password'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic03.id
        }
      ]
    }
  }
}


resource vm04 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-consumer-04'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'vm-consumer-04'
      adminUsername: 'azureuser'
      adminPassword: 'Azure12345!Password'
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic04.id
        }
      ]
    }
  }
}
