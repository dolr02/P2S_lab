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

@secure()
#disable-next-line no-unused-params
param adminPassword string

#disable-next-line no-unused-params
param usePublicIp bool = true
