param location string = resourceGroup().location

@secure()
param adminPassword string

param adminUsername string = 'radek'

// IMAGE VM NIC
resource nicImage 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: 'nic-image'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              'vnet-dev-eus-01',
              'snet-images-web'
            )
          }
        }
      }
    ]
  }
}

// VIDEO VM NIC
resource nicVideo 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: 'nic-video'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              'vnet-dev-eus-01',
              'snet-videos-web'
            )
          }
        }
      }
    ]
  }
}

// IMAGE VM
resource vmImage 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'vm-image'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vmimage'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicImage.id
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
    }
  }
}

// VIDEO VM
resource vmVideo 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: 'vm-video'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vmvideo'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicVideo.id
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
    }
  }
}
