module vnets './Vnets/bicep/main.bicep' = {
  name: 'deployVnets'
}

module vms './VM/bicep/main.bicep' = {
  name: 'deployVMs'
}

module gateway './Gateway/bicep/main.bicep' = {
  name: 'deployGateway'
}

