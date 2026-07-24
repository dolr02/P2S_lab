param location string = resourceGroup().location

param vmSize string = 'Standard_B2s'

param adminUsername string = 'azureuser'

@secure()
param adminPassword string

param vnetName string
param subnetName string

var vmCount = 4
var vmPrefix = 'vm-provider-'

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-provider-vm'
  location: location

  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-SSH'
        properties: {
          priority: 110
          access: 'Allow'
          direction: 'Inbound'
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

    name: 'nic-provider-0${i}'
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
              id: resourceId(
                'Microsoft.Network/virtualNetworks/subnets',
                vnetName,
                subnetName
              )
            }
          }
        }
      ]
    }
  }
]


resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = [
  for i in range(1, vmCount + 1): {

    name: '${vmPrefix}0${i}'
    location: location

    properties: {

      hardwareProfile: {
        vmSize: vmSize
      }

      osProfile: {
        computerName: '${vmPrefix}0${i}'
        adminUsername: adminUsername

        linuxConfiguration: {
          disablePasswordAuthentication: false
        }

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
            id: nic[i-1].id
          }
        ]
      }

    }
  }
]
