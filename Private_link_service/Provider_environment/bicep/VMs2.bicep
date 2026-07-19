targetScope = 'resourceGroup'

param location string = resourceGroup().location
param backendPoolId string

resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-provider-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet-provider', 'app-subnet')
          }
          loadBalancerBackendAddressPools: [
            {
              id: backendPoolId
            }
          ]
        }
      }
    ]
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
      adminUsername: 'radek'
      adminPassword: 'Radek123!'
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
