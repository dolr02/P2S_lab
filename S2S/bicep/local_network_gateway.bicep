param lngName string = 'lng-onprem'
param onPremPublicIp string = '192.168.1.4'

param onPremAddressSpace array = [
  '192.168.0.0/16'
]

resource localGw 'Microsoft.Network/localNetworkGateways@2023-09-01' = {
  name: lngName
  location: resourceGroup().location
  properties: {
    gatewayIpAddress: onPremPublicIp
    localNetworkAddressSpace: {
      addressPrefixes: onPremAddressSpace
    }
  }
}
