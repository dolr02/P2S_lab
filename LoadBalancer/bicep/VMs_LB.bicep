param location string = resourceGroup().location

@allowed([
  2
  3
])
param vmCount int = 2

param adminUsername string = 'radek'

@secure()
param adminPassword string

param vnetName string = 'vnet-dev-eus-01'
param subnetName string = 'snet-dev-eus-01'
param lbName string = 'lb-dev-eus-01'
param backendPoolName string = 'be-az700-eus-dev-01'

var backendPoolId = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  lbName,
  backendPoolName
)

module webVms './VM_Vnet.bicep' = [
  for i in range(1, vmCount): {
    name: 'deploy-web-vm-${i}'
    params: {
      location: location
      vmName: 'vm-web-eus-0${i}'
      nicName: 'nic-web-eus-0${i}'
      vnetName: vnetName
      subnetName: subnetName
      adminUsername: adminUsername
      adminPassword: adminPassword
      backendPoolId: backendPoolId
      installWebServer: true
    }
  }
]
