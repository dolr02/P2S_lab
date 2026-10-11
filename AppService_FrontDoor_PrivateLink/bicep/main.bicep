param webAppName string = 'afd-pl-lab-202610'
param profileName string = 'afd-pl-lab-profile-202610'
param endpointName string = 'afd-pl-lab-ep-202610'
param originLocation string = 'Central India'

module frontDoor './front-door.bicep' = {
  name: 'frontDoorDeployment'
  params: {
    webAppName: webAppName
    profileName: profileName
    endpointName: endpointName
    originLocation: originLocation
  }
}

output profileName string = frontDoor.outputs.profileName
output endpointName string = frontDoor.outputs.endpointName
output endpointHostName string = frontDoor.outputs.endpointHostName
