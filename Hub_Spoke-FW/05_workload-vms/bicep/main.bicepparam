using './main.bicep'

param location = 'eastus'

param adminUsername = 'azureadmin'
param adminPassword = 'ChangeMe123!'

param spoke1VnetName = 'vnet-spoke1-eus-01'
param spoke2VnetName = 'vnet-spoke2-eus-01'

param subnetName = 'snet-workload'

param vmSize = 'Standard_B2s'
