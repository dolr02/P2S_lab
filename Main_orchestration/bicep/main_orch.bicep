@secure()
param adminPassword string
param adminUsername string = 'azureuser'

param devVnetName string = 'vnet-dev-eus-01'
param devSubnetName string = 'snet-dev-eus-01'

param tstVnetName string = 'vnet-tst-eus-01'
param tstSubnetName string = 'snet-tst-eus-01'

param devResourceGroup string = 'rg-p2s-lab'
param location string = resourceGroup().location

//
// VNETS – nemají parametry, proto žádné params!
//
module vnets '../Vnets/bicep/main.bicep' = {
  name: 'deployVnets'
}

//
// VMS – mají 6 parametrů, proto je MUSÍŠ poslat
//
module vms '../VM/bicep/main.bicep' = {
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

//
// VPN GATEWAY – správný soubor je GTW.bicep
//
module gateway '../VPN_GTW/bicep/GTW.bicep' = {
  name: 'deployGateway'
  params: {
    devVnetName: devVnetName
    devResourceGroup: devResourceGroup
    location: location
  }
}
