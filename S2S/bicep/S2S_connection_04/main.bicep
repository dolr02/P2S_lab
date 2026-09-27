param location string = resourceGroup().location

param gatewayName string = 'vpngw-dev-eus-01'
param rrasPublicIpName string = 'pip-vm-onprem-rras-01'
param localNetworkGatewayName string = 'lng-onprem-rras'
param connectionName string = 'conn-azure-to-rras'

@secure()
param sharedKey string

resource gw 'Microsoft.Network/virtualNetworkGateways@2023-09-01' existing = {
  name: gatewayName
}

resource rrasPip 'Microsoft.Network/publicIPAddresses@2023-09-01' existing = {
  name: rrasPublicIpName
}

resource lng 'Microsoft.Network/localNetworkGateways@2023-09-01' = {
  name: localNetworkGatewayName
  location: location
  properties: {
    gatewayIpAddress: rrasPip.properties.ipAddress
    localNetworkAddressSpace: {
      addressPrefixes: [
        '192.168.1.0/24'
      ]
    }
  }
}

resource connection 'Microsoft.Network/connections@2023-09-01' = {
  name: connectionName
  location: location
  properties: {
    connectionType: 'IPsec'

    virtualNetworkGateway1: {
      id: gw.id
      properties: {}
    }

    localNetworkGateway2: {
      id: lng.id
      properties: {}
    }

    sharedKey: sharedKey
    enableBgp: false
    connectionProtocol: 'IKEv2'
    usePolicyBasedTrafficSelectors: false
  }
}

output connectionId string = connection.id
