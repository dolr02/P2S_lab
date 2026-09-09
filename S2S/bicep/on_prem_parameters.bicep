param vnetName string = 'vnet-onprem-dev-eus-01'

param subnetName string = 'snet-onprem-servers'

param subnetPrefix string = '192.168.1.0/24'

param vmName string = 'vm-prem-vpn-01'

param adminUsername string = 'azureuser'

@secure()
param adminPassword string

module onprem './on_prem_main.bicep' = {
  name: 'onprem'
  params: {
    vnetName: vnetName
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    vmName: vmName
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}
