param location string = resourceGroup().location
param adminUsername string = 'labadmin'

@secure()
param adminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: 'vnet-f5-lab'
}

resource managementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: 'snet-f5-mgmt'
}

resource monitoringNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'nic-f5-monitoring'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: managementSubnet.id
          }
        }
      }
    ]
  }
}

resource monitoringVm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'VM-F5-Monitoring'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
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
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'vm-f5-monitoring'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: monitoringNic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}
