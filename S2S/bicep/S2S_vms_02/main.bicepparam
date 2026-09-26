using './main.bicep'

param azureVnetName = 'vnet-dev-eus-01'
param onpremVnetName = 'vnet-onprem-eus-01'

param azureSubnetName = 'snet-azure-vm'
param onpremSubnetName = 'snet-onprem'

param adminUsername = 'azureadmin'
param adminPassword = 'ChangeMe123!'

param vmSize = 'Standard_B2s'
