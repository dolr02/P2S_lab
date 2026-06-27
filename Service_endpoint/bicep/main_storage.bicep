@description('Name of the Storage Account')
param storageAccountName string

@description('Enable Azure Data Lake Storage Gen2 (hierarchical namespace)')
param enableAdlsGen2 bool = false

@allowed([
  'Standard_GRS'
])
@description('Replication type')
param skuName string = 'Standard_GRS'

@description('Location of the Storage Account')
param location string = 'eastus'

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    isHnsEnabled: enableAdlsGen2
  }
}
