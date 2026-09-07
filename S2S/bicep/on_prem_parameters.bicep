#disable-next-line no-unused-params
param vnetName string = 'vnet-onprem-dev-eus-01'

#disable-next-line no-unused-params
param subnets array = [
  {
    name: 'snet-onprem-servers'
    prefix: '192.168.1.0/24'
  }
]

#disable-next-line no-unused-params
param vmName string = 'vm-prem-vpn-01'

#disable-next-line no-unused-params
param adminUsername string = 'azureadmin'

#disable-next-line no-unused-params
param vmSubnetName string = 'snet-onprem-servers'

#disable-next-line no-unused-params
param vnetAddressPrefix string = '192.168.1.0/24'

@secure()
#disable-next-line no-unused-params
param adminPassword string

#disable-next-line no-unused-params
param usePublicIp bool = true

module onprem './on_prem_main.bicep' = {
  name: 'onprem'
  params: {
    vnetName: vnetName
    subnets: subnets
    vmName: vmName
    adminUsername: adminUsername
    vmSubnetName: vmSubnetName
    vnetAddressPrefix: vnetAddressPrefix
    adminPassword: adminPassword
    usePublicIp: usePublicIp
  }
}
