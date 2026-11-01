targetScope = 'resourceGroup'

param location string = resourceGroup().location

param spoke1VnetName string = 'vnet-spoke1-eus-01'
param spoke2VnetName string = 'vnet-spoke2-eus-01'

param subnetName string = 'snet-workload'

param adminUsername string

@secure()
param adminPassword string

param vmSize string = 'Standard_B2s'

resource spoke1Vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: spoke1VnetName
}

resource spoke2Vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: spoke2VnetName
}

resource spoke1Subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: spoke1Vnet
  name: subnetName
}

resource spoke2Subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: spoke2Vnet
  name: subnetName
}

resource spoke1Nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-vm-spoke1-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.1.4'
          subnet: {
            id: spoke1Subnet.id
          }
        }
      }
    ]
  }
}

resource spoke2Nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-vm-spoke2-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.2.1.4'
          subnet: {
            id: spoke2Subnet.id
          }
        }
      }
    ]
  }
}

var imageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-azure-edition'
  version: 'latest'
}

resource spoke1Vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-spoke1-01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'spoke101'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: spoke1Nic.id
        }
      ]
    }
  }
}

resource spoke2Vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-spoke2-01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'spoke201'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: spoke2Nic.id
        }
      ]
    }
  }
}
