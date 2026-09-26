using './main.bicep'

param location = 'eastus'
param adminUsername = 'azureadmin'
param adminPassword = 'ChangeMe123!'

param azureSubnetName = 'snet-azure-vm'
param azureVnetName = 'vnet-dev-eus-01'
param onpremSubnetName = 'snet-onprem'
param onpremVnetName = 'vnet-onprem-eus-01'
param vmSize = 'Standard_B2s'
