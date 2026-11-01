using './main.bicep'

param location = 'eastus'

param firewallPrivateIp = '10.0.1.4'

param spoke1VnetName = 'vnet-spoke1-eus-01'
param spoke2VnetName = 'vnet-spoke2-eus-01'

param spoke1SubnetName = 'snet-workload'
param spoke2SubnetName = 'snet-workload'
