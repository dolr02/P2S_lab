targetScope = 'resourceGroup'

param location string = resourceGroup().location

param adminUsername string = 'azureuser'

@secure()
param adminPassword string

var vmCount = 4

var vnetName = 'vnet-consumer'
var subnetName = 'snet-vm'

var vmPrefix = 'pl-consumer-vm'
var nicPrefix = 'pl-consumer-nic'


resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetName
}


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {

  name: 'nsg-pl-consumer-vm'

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

    name: '${nicPrefix}-${i}'

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

    name: '${vmPrefix}-${i}'

    location: location


    properties: {

      hardwareProfile: {

        vmSize: 'Standard_B1s'

      }


      osProfile: {

        computerName: '${vmPrefix}-${i}'

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

            id: nic[i - 1].id

          }

        ]

      }

    }

  }

]


output vmNames array = [

  for i in range(1, vmCount + 1): '${vmPrefix}-${i}'

]
