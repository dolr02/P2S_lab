targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

param azureVnetName string
param onpremVnetName string

param azureSubnetName string
param onpremSubnetName string

param adminUsername string

@secure()
param adminPassword string

param vmSize string

resource azureVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: azureVnetName
}

resource onpremVnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: onpremVnetName
}

resource azureSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: azureVnet
  name: azureSubnetName
}

resource onpremSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: onpremVnet
  name: onpremSubnetName
}

resource rrasPip 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'pip-vm-onprem-rras-01'
  location: location

  sku: {
    name: 'Standard'
  }

  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource rrasNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-vm-onprem-rras-01'
  location: location

  properties: {
    securityRules: [
      {
        name: 'Allow-IKE'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '500'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-NATT'
        properties: {
          priority: 110
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '4500'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-RDP'
        properties: {
          priority: 120
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource rrasNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-vm-onprem-rras-01'
  location: location

  properties: {
    enableIPForwarding: true

    networkSecurityGroup: {
      id: rrasNsg.id
    }

    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.1.4'

          subnet: {
            id: onpremSubnet.id
          }

          publicIPAddress: {
            id: rrasPip.id
          }
        }
      }
    ]
  }
}

resource clientNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-vm-onprem-client-01'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.1.5'

          subnet: {
            id: onpremSubnet.id
          }
        }
      }
    ]
  }
}

resource azureNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: 'nic-vm-azure-01'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'

        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.0.4'

          subnet: {
            id: azureSubnet.id
          }
        }
      }
    ]
  }
}

var imageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-azure-edition'
  version: 'latest'
}

resource rrasVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-onprem-rras-01'
  location: location

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: 'rras01'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }

    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: rrasNic.id
        }
      ]
    }
  }
}

resource clientVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-onprem-client-01'
  location: location

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: 'client01'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }

    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: clientNic.id
        }
      ]
    }
  }
}

resource azureVm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: 'vm-azure-01'
  location: location

  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: 'azure01'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }

    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: azureNic.id
        }
      ]
    }
  }
}

output rrasPublicIp string = rrasPip.properties.ipAddress
