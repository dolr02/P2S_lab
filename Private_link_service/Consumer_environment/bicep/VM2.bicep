param location string = resourceGroup().location


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: 'snet-vm'

  parent: resourceId(
    'Microsoft.Network/virtualNetworks',
    'vnet-consumer'
  )
}


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-consumer-vm'
  location: location

  properties: {
    securityRules: [
      {
        name: 'allowSSH'

        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'

          sourcePortRange: '*'
          sourceAddressPrefix: '*'

          destinationPortRange: '22'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-consumer-vm'
  location: location

  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }

    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          privateIPAllocationMethod: 'Dynamic'

          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'vm-consumer-01'
  location: location

  properties: {

    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }

    osProfile: {
      computerName: 'consumer01'
      adminUsername: 'azureuser'
      adminPassword: 'Azure123456789!'
    }

    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
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


output vmId string = vm.id

output nicId string = nic.id
