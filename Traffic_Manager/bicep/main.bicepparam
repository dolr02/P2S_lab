using './main.bicep'

param profileName = 'tm-hybrid-lab'
param dnsLabel = 'tm-hybrid-lab-dolr02-01'

param dnsTtl = 30

param monitorProtocol = 'HTTP'
param monitorPort = 80
param monitorPath = '/'

param probeInterval = 30
param probeTimeout = 10
param toleratedFailures = 3

param childProfileName = 'tm-performance-lab'

param onpremFqdn = 'onprem-kjpwu2bkc3vsk.eastus.cloudapp.azure.com'
