param location string = resourceGroup().location
param adminUsername string = 'f5admin'

@secure()
param adminPassword string

var publisher = 'f5-networks'
var offer = 'f5-big-ip-good'
var imageSku = 'f5-bigip-virtual-edition-25m-good-hourly'

resource mgmtNic 'Microsoft.Network/networkInterfaces@2024-05-01' existing = {
  name: 'nic-f5-mgmt'
}

resource externalNic 'Microsoft.Network/networkInterfaces@2024-05-01' existing = {
  name: 'nic-f5-external'
}

resource internalNic 'Microsoft.Network/networkInterfaces@2024-05-01' existing = {
  name: 'nic-f5-internal'
}

resource bigip 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'vm-f5-bigip'
  location: location
  plan: {
    publisher: publisher
    product: offer
    name: imageSku
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D8s_v4'
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: imageSku
        version: '21.1.0030000'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'vm-f5-bigip'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: mgmtNic.id
          properties: {
            primary: true
          }
        }
        {
          id: externalNic.id
          properties: {
            primary: false
          }
        }
        {
          id: internalNic.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}
