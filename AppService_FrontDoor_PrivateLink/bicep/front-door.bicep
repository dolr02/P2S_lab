param webAppName string = 'afd-pl-lab-202610'
param profileName string = 'afd-pl-lab-profile-202610'
param endpointName string = 'afd-pl-lab-ep-202610-bzhkgfg7dxeqg0gw'
param originLocation string = 'Central India'

output webAppName string = webAppName
output profileName string = profileName
output endpointName string = endpointName
output endpointHostName string = '${endpointName}.z02.azurefd.net'
output originLocation string = originLocation
