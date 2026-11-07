param location string = 'eastus'
param vmName string = 'vm-new-eus-01'
param nicName string = 'nic-new-eus-01'
param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'
param adminUsername string = 'radek'

@secure()
param adminPassword string

@description('Volitelné ID backend poolu LB.')
param backendPoolId string = ''

@description('Volitelná instalace HTTP serveru a vytvoření NSG.')
param installWebServer bool = false

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  parent: vnet
  name: subnetName
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2022-05-01' = if (installWebServer) {
  name: '${vmName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-LB-Probe'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    networkSecurityGroup: installWebServer ? {
      id: nsg!.id
    } : null
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          loadBalancerBackendAddressPools: empty(backendPoolId) ? [] : [
            {
              id: backendPoolId
            }
          ]
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
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

resource webServer 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if (installWebServer) {
  parent: vm
  name: 'install-nginx'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'bash -c "set -e; export DEBIAN_FRONTEND=noninteractive; apt-get -o Acquire::Retries=5 update; apt-get -o Acquire::Retries=5 install -y nginx; echo \'<h1>${vmName}</h1>\' > /var/www/html/index.html; systemctl enable --now nginx; curl --fail http://localhost/"'
    }
  }
}

output deployedVmName string = vm.name
