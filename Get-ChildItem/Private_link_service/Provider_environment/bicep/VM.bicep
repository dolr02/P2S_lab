targetScope = 'resourceGroup'

param location string = resourceGroup().location

param backendPoolId string


resource nsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {

  name: 'nsg-provider-vm'

  location: location

  properties: {

    securityRules: [

      {
        name: 'AllowHTTP'

        properties: {

          priority: 100

          direction: 'Inbound'

          access: 'Allow'

          protocol: 'Tcp'

          sourcePortRange: '*'

          destinationPortRange: '80'

          sourceAddressPrefix: '*'

          destinationAddressPrefix: '*'
        }
      }


      {
        name: 'AllowSSH'

        properties: {

          priority: 110

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



resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {

  name: 'nic-provider-01'

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
              'vnet-provider',
              'app-subnet'
            )
          }


          loadBalancerBackendAddressPools: [

            {
              id: backendPoolId
            }
          ]
        }
      }
    ]


    networkSecurityGroup: {

      id: nsg.id

    }
  }
}



resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {

  name: 'vm-provider-01'

  location: location


  properties: {


    hardwareProfile: {

      vmSize: 'Standard_B1s'

    }


    osProfile: {

      computerName: 'vm-provider-01'

      adminUsername: 'azureuser'

      adminPassword: 'AzureLab123456789!'


      customData: base64('''#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Hello from Private Link Service Provider VM" > /var/www/html/index.html
''')

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



output vmId string = vm.id

output nicId string = nic.id
