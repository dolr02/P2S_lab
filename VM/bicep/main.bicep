@secure()
param adminPassword string
param adminUsername string = 'azureuser'

param devVnetName string = 'vnet-dev-eus-01'
param devSubnetName string = 'snet-dev-eus-web'   // ← tady web

param tstVnetName string = 'vnet-tst-eus-01'
param tstSubnetName string = 'snet-tst-eus-app'   // ← tady app

module vms 'vm.bicep' = {
  name: 'deployVMs'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername

    devVnetName: devVnetName
    devSubnetName: devSubnetName

    tstVnetName: tstVnetName
    tstSubnetName: tstSubnetName
  }
}
