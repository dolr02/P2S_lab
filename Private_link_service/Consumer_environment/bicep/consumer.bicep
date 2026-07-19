targetScope = 'resourceGroup'

param location string = resourceGroup().location

//
// CONSUMER VNET
//
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-consumer'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'vm-subnet'
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

//
// NIC
//
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-consumer-vm'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(
              'Microsoft.Network/virtualNetworks/subnets',
              'vnet-consumer',
              'vm-subnet'
            )
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

//
// VM
//
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-consumer'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-consumer'
      adminUsername: 'azureuser'
      adminPassword: 'Password123!'
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

output vnetId string = vnet.id
output peSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-consumer', 'pe-subnet')
