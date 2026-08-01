param location string = resourceGroup().location

param vnetName string = 'vnet-dev-eus-01'

param vmVideoName string = 'vm-video'
param vmImageName string = 'vm-image'

param adminUsername string = 'azureuser'

@secure()
param adminPassword string


resource vnet 'Microsoft.Network/virtualNetworks@2022-09-01' existing = {
  name: vnetName
}


// =====================
// SUBNETS
// =====================

resource videoSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vnet
  name: 'snet-videos-web'

  properties: {
    addressPrefix: '10.0.20.0/24'
  }
}


resource imageSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-09-01' = {
  parent: vnet
  name: 'snet-images-web'

  properties: {
    addressPrefix: '10.0.30.0/24'
  }
}


// =====================
// NSG
// =====================

resource webNsg 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {

  name: 'nsg-web-backend'

  location: location


  properties: {

    securityRules: [

      {
        name: 'allow-http'

        properties: {

          priority: 100

          direction: 'Inbound'

          access: 'Allow'

          protocol: 'Tcp'

          sourcePortRange: '*'

          destinationPortRange: '80'

          sourceAddressPrefix: '*'

          destinationAddressPrefix: '*'

        }
      }

      {
        name: 'allow-ssh'

        properties: {

          priority: 200

          direction: 'Inbound'

          access: 'Allow'

          protocol: 'Tcp'

          sourcePortRange: '*'

          destinationPortRange: '22'

          sourceAddressPrefix: '*'

          destinationAddressPrefix: '*'

        }
      }

    ]
  }
}



// =====================
// NIC VIDEO
// =====================

resource nicVideo 'Microsoft.Network/networkInterfaces@2022-09-01' = {

  name: '${vmVideoName}-nic'

  location: location


  properties: {

    networkSecurityGroup: {
      id: webNsg.id
    }


    ipConfigurations: [

      {

        name: 'ipconfig1'

        properties: {

          privateIPAllocationMethod: 'Dynamic'


          subnet: {
            id: videoSubnet.id
          }

        }
      }

    ]
  }
}



// =====================
// NIC IMAGE
// =====================

resource nicImage 'Microsoft.Network/networkInterfaces@2022-09-01' = {

  name: '${vmImageName}-nic'

  location: location


  properties: {

    networkSecurityGroup: {
      id: webNsg.id
    }


    ipConfigurations: [

      {

        name: 'ipconfig1'

        properties: {

          privateIPAllocationMethod: 'Dynamic'


          subnet: {
            id: imageSubnet.id
          }

        }
      }

    ]
  }
}



// =====================
// CLOUD INIT
// =====================

var nginxVideo = '''
#!/bin/bash
apt update
apt install nginx -y
echo "VIDEO BACKEND OK - vm-video" > /var/www/html/index.html
systemctl enable nginx
systemctl restart nginx
'''


var nginxImage = '''
#!/bin/bash
apt update
apt install nginx -y
echo "IMAGE BACKEND OK - vm-image" > /var/www/html/index.html
systemctl enable nginx
systemctl restart nginx
'''



// =====================
// VM VIDEO
// =====================

resource vmVideo 'Microsoft.Compute/virtualMachines@2023-03-01' = {

  name: vmVideoName

  location: location


  properties: {

    hardwareProfile: {

      vmSize: 'Standard_B2s'

    }


    osProfile: {

      computerName: vmVideoName

      adminUsername: adminUsername

      adminPassword: adminPassword


      customData: base64(nginxVideo)

    }


    storageProfile: {

      imageReference: {

        publisher: 'Canonical'

        offer: '0001-com-ubuntu-server-jammy'

        sku: '22_04-lts-gen2'

        version: 'latest'

      }


      osDisk: {

        createOption: 'FromImage'

      }

    }


    networkProfile: {

      networkInterfaces: [

        {

          id: nicVideo.id

        }

      ]

    }

  }
}



// =====================
// VM IMAGE
// =====================

resource vmImage 'Microsoft.Compute/virtualMachines@2023-03-01' = {

  name: vmImageName

  location: location


  properties: {

    hardwareProfile: {

      vmSize: 'Standard_B2s'

    }


    osProfile: {

      computerName: vmImageName

      adminUsername: adminUsername

      adminPassword: adminPassword


      customData: base64(nginxImage)

    }


    storageProfile: {

      imageReference: {

        publisher: 'Canonical'

        offer: '0001-com-ubuntu-server-jammy'

        sku: '22_04-lts-gen2'

        version: 'latest'

      }


      osDisk: {

        createOption: 'FromImage'

      }

    }


    networkProfile: {

      networkInterfaces: [

        {

          id: nicImage.id

        }

      ]

    }

  }
}
