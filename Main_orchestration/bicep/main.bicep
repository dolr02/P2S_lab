param location string = resourceGroup().location

//
// VNETS modul
//
module vnets '../Vnets/bicep/main.bicep' = {
  name: 'deployVnets'
  params: {
    location: location
  }
}

//
// VMS modul
//
module vms '../VM/bicep/main.bicep' = {
  name: 'deployVMs'
  params: {
    location: location
  }
}

//
// VPN GATEWAY modul
//
module gateway '../VPN_GTW/bicep/GTW.bicep' = {
  name: 'deployGateway'
  params: {
    devVnetName: 'vnet-dev-eus-01'
    devResourceGroup: 'rg-p2s-lab'
    location: location
  }
}
