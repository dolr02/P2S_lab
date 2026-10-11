param webAppName string = 'afd-pl-lab-202610'
param profileName string = 'afd-pl-lab-profile-202610'
param endpointName string = 'afd-pl-lab-ep-202610'
param originLocation string = 'Central India'

resource webApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webAppName
}

output profileName string = profileName
output endpointName string = endpointName
output endpointHostName string = webApp.properties.defaultHostName
output originLocation string = originLocation
