module vnets '../Vnets/bicep/main.bicep' = {
  name: 'deployVnets'
}

module vms '../VM/bicep/main.bicep' = {
  name: 'deployVMs'
}

module gateway '../VPN_GTW/bicep/main.bicep' = {
  name: 'deployGateway'
}
