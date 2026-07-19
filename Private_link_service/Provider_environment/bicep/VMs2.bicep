targetScope = 'resourceGroup'

param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'
param backendPoolId string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  name: subnetName
  parent: vnet
}

//
// NICs
//
resource nic1 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-dev-web-01'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
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

resource nic2 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-dev-web-02'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
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

//
// CLOUD-INIT FOR NGINX
//
var cloudInit = '''
#cloud-config
package_update: true
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
'''

//
// VM1
//
resource vm1 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-dev-web-01'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-dev-web-01'
      adminUsername: 'azureuser'
      adminPassword: 'Password123!'
      customData: base64(cloudInit)
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
          id: nic1.id
        }
      ]
    }
  }
}

//
// VM2
//
resource vm2 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-dev-web-02'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-dev-web-02'
      adminUsername: 'azureuser'
      adminPassword: 'Password123!'
      customData: base64(cloudInit)
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
          id: nic2.id
        }
      ]
    }
  }
}
