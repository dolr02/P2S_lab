param location string = resourceGroup().location
param adminUsername string = 'labadmin'

@secure()
param adminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: 'vnet-f5-lab'
}

resource internalSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: 'snet-f5-internal'
}

resource backendNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'nic-f5-backend'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: internalSubnet.id
          }
        }
      }
    ]
  }
}

var cloudInit = '''
#cloud-config
write_files:
  - path: /var/www/f5-lab/index.html
    content: |
      F5 backend OK
  - path: /etc/systemd/system/f5-lab-backend.service
    content: |
      [Unit]
      Description=F5 lab HTTP backend

      [Service]
      User=www-data
      ExecStart=/usr/bin/python3 -m http.server 8080 --directory /var/www/f5-lab
      Restart=on-failure

      [Install]
      WantedBy=multi-user.target
runcmd:
  - [systemctl, daemon-reload]
  - [systemctl, enable, --now, f5-lab-backend.service]
'''

resource backendVm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'VM-F5-Backend'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
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
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'vm-f5-backend'
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: base64(cloudInit)
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: backendNic.id
          properties: {
            primary: true
          }
        }
      ]
    }
  }
}
