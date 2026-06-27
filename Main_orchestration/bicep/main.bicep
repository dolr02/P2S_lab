param adminUsername string = 'azureuser'
@secure()
param adminPassword string

module vnets './Vnets/main.bicep' = {
  name: 'deployVnets'
}

module vms './VM/main.bicep' = {
  name: 'deployVMs'
  params: {
    adminUsername: adminUsername
    adminPassword: adminPassword

    devVnetName: vnets.outputs.devVnetName
    devSubnetName: vnets.outputs.devSubnetName

    tstVnetName: vnets.outputs.tstVnetName
    tstSubnetName: vnets.outputs.tstSubnetName
  }
}

module gateway './GTW_bicep/main.bicep' = {
  name: 'deployGateway'
  params: {
    devVnetName: vnets.outputs.devVnetName
  }
}

