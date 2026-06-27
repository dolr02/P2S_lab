param location string = resourceGroup().location

module vnets '../Vnets/bicep/main.bicep' = {
  name: 'deployVnets'
  params: {
    location: location
  }
}

module vms '../VM/bicep/main.bicep' = {
  name: 'deployVMs'
  params: {
    location: location
  }
}

module gateway '../VPN_GTW/bicep/main.bicep' = {
  name: 'deployGateway'
  params: {
    location: location
  }
}
