targetScope = 'resourceGroup'

param location string = resourceGroup().location

param vnetName string = 'vnet-consumer-eus-01'

param vmName string = 'vm-consumer-eus-01'

param adminUsername string = 'azureuser'


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
        '10.10.0.0/16'
      ]
    }


    subnets: [

      {
        name: 'consumer-subnet'

        properties: {
          addressPrefix: '10.10.1.0/24'

          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }


      {
        name: 'pe-subnet'

        properties: {
          addressPrefix: '10.10.2.0/24'

          privateEndpointNetworkPolicies: 'Disabled'
        }
      }

    ]
  }
}


resource publicIP 'Microsoft.Network/publicIPAddresses@2023-05-01' = {

  name: '${vmName}-pip'

  location: location

  properties: {

    publicIPAllocationMethod: 'Static'

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


          publicIPAddress: {
            id: publicIP.id
          }


          subnet: {

            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              vnetName,
              'consumer-subnet'
            )
          }
        }
      }
    ]
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {

  name: vmName

  location: location


  properties: {

    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }


    osProfile: {

      computerName: vmName

      adminUsername: adminUsername

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
          id: nic.id
        }
      ]
    }
  }
}


output vmPrivateIP string = nic.properties.ipConfigurations[0].properties.privateIPAddress

output peSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'pe-subnet'
)
