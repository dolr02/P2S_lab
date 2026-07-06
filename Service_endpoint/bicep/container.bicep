param saName string
param containerName string = 'scripts'

resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: saName
}

resource scriptsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${saName}/default/${containerName}'
  properties: {
    publicAccess: 'None'
  }
}

