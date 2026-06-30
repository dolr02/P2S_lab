// Najdi storage account podle tagu purpose = p2s-lab-storage
var storageAccounts = resourceGroup().resources
  |> where(r => r.type == 'Microsoft.Storage/storageAccounts')
  |> where(r => r.tags.purpose == 'p2s-lab-storage')

// Vezmi první nalezený storage account
var saName = storageAccounts[0].name

// EXISTING storage account
resource sa 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: saName
}

// Container v blob service
resource scriptsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${sa.name}/default/scripts'
  properties: {
    publicAccess: 'None'
  }
}


