targetScope = 'resourceGroup'

param location string = resourceGroup().location

var vmCount = 4

resource ilb 'Microsoft.Network/loadBalancers@2023-09-01' existing = {
  name: 'ilb-provider'
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: 'vnet-provider'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: 'app-subnet'
}

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
              id: subnet.id
            }

            loadBalancerBackendAddressPools: [
              {
                id: resourceId(
                  'Microsoft.Network/loadBalancers/backendAddressPools',
                  ilb.name,
                  'backend-pool'
                )
              }
            ]
          }
        }
      ]
    }
  }
]

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = [
  for i in range(1, vmCount + 1): {

    name: 'vm-provider-0${i}'
    location: location

    properties: {

      hardwareProfile: {
        vmSize: 'Standard_B1s'
      }

      osProfile: {
        computerName: 'vm-provider-0${i}'
        adminUsername: 'azureuser'
        adminPassword: 'AzureLab123456789!'

        customData: base64('''#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Hello from Provider VM ${i}" > /var/www/html/index.html
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
            id: nic[i - 1].id
          }
        ]
      }
    }
  }
]

output vmNames array = [
  for i in range(1, vmCount + 1): 'vm-provider-0${i}'
]
