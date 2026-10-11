param webAppName string = 'afd-pl-lab-202610'
param profileName string = 'afd-pl-lab-profile-202610'
param endpointName string = 'afd-pl-lab-ep-202610'
param originLocation string = 'Central India'

resource webApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: webAppName
}

resource profile 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2024-02-01' = {
  parent: profile
  name: endpointName
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2024-02-01' = {
  parent: profile
  name: 'appservice-origin-group'
  properties: {
    loadBalancingSettings: {
      additionalLatencyInMilliseconds: 50
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: {
      probePath: '/'
      probeRequestType: 'HEAD'
      probeProtocol: 'Https'
      probeIntervalInSeconds: 100
    }
    sessionAffinityState: 'Disabled'
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2024-02-01' = {
  parent: originGroup
  name: 'appservice-origin'
  properties: {
    hostName: webApp.properties.defaultHostName
    originHostHeader: webApp.properties.defaultHostName
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
    sharedPrivateLinkResource: {
      privateLink: {
        id: webApp.id
      }
      groupId: 'sites'
      privateLinkLocation: originLocation
      requestMessage: 'AFD Premium Private Link Lab'
    }
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2024-02-01' = {
  parent: endpoint
  name: 'route1'
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output profileName string = profile.name
output endpointName string = endpoint.name
output endpointHostName string = endpoint.properties.hostName
output originLocation string = originLocation
output originGroupName string = originGroup.name
output originName string = origin.name
output routeName string = route.name
