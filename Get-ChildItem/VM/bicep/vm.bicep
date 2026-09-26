@secure()
param adminPassword string
param adminUsername string = 'azureuser'
param location string = resourceGroup().location

param devVnetName string = 'vnet-dev-eus-01'
param devSubnetName string = 'snet-dev-eus-01'

param tstVnetName string = 'vnet-tst-eus-01'
param tstSubnetName string = 'snet-tst-eus-01'

// DEV NIC
resource nicDev 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-dev-eus-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', devVnetName, devSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// TST NIC
resource nicTst 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-tst-eus-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', tstVnetName, tstSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

// DEV VM
resource vmDev 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-dev-eus-01'
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
    osProfile: {
      computerName: 'vm-dev-eus-01'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: { disablePasswordAuthentication: false }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
    networkProfile: {
      networkInterfaces: [ { id: nicDev.id } ]
    }
  }
}

// TST VM
resource vmTst 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-tst-eus-01'
  location: location
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' }
    osProfile: {
      computerName: 'vm-tst-eus-01'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: { disablePasswordAuthentication: false }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
    networkProfile: {
      networkInterfaces: [ { id: nicTst.id } ]
    }
  }
}

output devVmName string = vmDev.name
output tstVmName string = vmTst.name

