@description('Name of the Storage Account')
param storageAccountName string

resource scriptsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccountName}/default/scripts'
  properties: {
    publicAccess: 'None'
  }
}
