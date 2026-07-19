targetScope = 'resourceGroup'

param location string = resourceGroup().location


param vnetName string = 'vnet-consumer-eus-01'

param vmName string = 'vm-consumer-eus-01'


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


resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {

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
              vnetName,
              'consumer-subnet'
            )
          }

          privateIPAllocationMethod: 'Dynamic'
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

      adminUsername: 'azureuser'

      adminPassword: 'Azure12345678!Strong'
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


output consumerVnetId string = vnet.id

output peSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'pe-subnet'
)
