param vnetName string = 'vnet-dev-eus-01'

param subnetName string = 'snet-dev-eus-web'
param subnetPrefix string = '10.0.0.0/24'

param gatewaySubnetPrefix string = '10.0.255.0/27'

param vmName string = 'vm-dev-web-01'
param adminUsername string = 'azureuser'

@secure()
param adminPassword string

module azure './azure_main.bicep' = {
  name: 'azure'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    gatewaySubnetPrefix: gatewaySubnetPrefix
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}

