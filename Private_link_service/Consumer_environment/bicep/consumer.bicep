targetScope = 'resourceGroup'

var location = 'eastus'

var vnetName = 'vnet-consumer-eus-01'
var vmName = 'vm-consumer-eus-01'

var adminUsername = 'azureuser'
var adminPassword = 'AzureLab123456789!'


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
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


resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
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
        name: 'snet-consumer-vm'

        properties: {
          addressPrefix: '10.20.1.0/24'

          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }


      {
        name: 'snet-private-endpoint'

        properties: {

          addressPrefix: '10.20.2.0/24'

          privateEndpointNetworkPolicies: 'Disabled'
        }
      }

    ]
  }
}



resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {

  name: '${vmName}-nic'

  location: location


  properties: {

    ipConfigurations: [

      {
        name: 'ipconfig1'

        properties: {

          privateIPAllocationMethod: 'Dynamic'

          subnet: {

            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              vnetName,
              'snet-consumer-vm'
            )

          }

        }

      }

    ]

  }

}




resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {

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




output consumerVnetName string = vnet.name

output consumerVmName string = vm.name

output privateEndpointSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'snet-private-endpoint'
)
