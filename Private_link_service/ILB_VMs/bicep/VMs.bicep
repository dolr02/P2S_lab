targetScope = 'resourceGroup'

param location string = resourceGroup().location

var vmCount = 4

var vnetName = 'vnet-consumer'
var subnetName = 'subnet-consumer'

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-consumer-vm'
  location: location

  properties: {
    securityRules: [
      {
        name: 'AllowSSH'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = [
  for i in range(1, vmCount + 1): {

    name: 'nic-consumer-0${i}'
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
]


resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = [
  for i in range(1, vmCount + 1): {

    name: 'vm-consumer-0${i}'
    location: location

    properties: {

      hardwareProfile: {
        vmSize: 'Standard_B1s'
      }

      osProfile: {
        computerName: 'vm-consumer-0${i}'
        adminUsername: 'azureuser'
        adminPassword: 'AzureLab123456789!'
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
            id: nic[i-1].id
          }
        ]
      }
    }
  }
]


output vmNames array = [
  for i in range(1, vmCount + 1): 'vm-consumer-0${i}'
]
