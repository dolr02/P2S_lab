resource nic02 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-consumer-02'
  location: 'eastus'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.1.2.5'
          subnet: {
            id: '/subscriptions/a48d08c6-0e09-428b-a68f-ae160e9abf86/resourceGroups/rg-consumer-dev-eus/providers/Microsoft.Network/virtualNetworks/vnet-consumer/subnets/snet-vm'
          }
        }
      }
    ]
  }
}


resource vm02 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-consumer-02'
  location: 'eastus'
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
      adminPassword: 'YourPasswordHere123!'
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
