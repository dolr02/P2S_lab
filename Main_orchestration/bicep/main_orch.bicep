param location string = resourceGroup().location

module vnets '../Vnets/bicep/main.bicep' = {
  name: 'deployVnets'
}

module vms '../VM/bicep/main.bicep' = {
  name: 'deployVMs'
}

module gateway '../VPN_GTW/bicep/GTW.bicep' = {
  name: 'deployGateway'
  params: {
    devVnetName: 'vnet-dev-eus-01'
    devResourceGroup: 'rg-p2s-lab'
    location: location
  }
}

