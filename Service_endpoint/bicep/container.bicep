// Najde storage account podle jména v resource group
resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource scriptsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${sa.name}/default/scripts'
  properties: {
    publicAccess: 'None'
  }
}
