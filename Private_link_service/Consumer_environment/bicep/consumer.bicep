targetScope = 'resourceGroup'

@description('Azure region')
param location string = resourceGroup().location

@description('Admin username for VM')
param adminUsername string

@secure()
@description('Admin password for VM')
param adminPassword string

@description('Consumer VM name')
param vmName string = 'vm-consumer-dev'

@description('Consumer VNet name')
param vnetName string = 'vnet-consumer-dev'


resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-consumer'
        properties: {
          addressPrefix: '10.20.1.0/24'
        }
      }
    ]
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              vnet.name,
              'snet-consumer'
            )
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
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
          id: nic.id
        }
      ]
    }
  }
}


output vmPrivateIP string = nic.properties.ipConfigurations[0].properties.privateIPAddress
output vmName string = vm.name
