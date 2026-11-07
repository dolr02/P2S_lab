using './main.bicep'

param profileName = 'tm-hybrid-lab'

// Změň suffix, aby byl název globálně unikátní.
param dnsLabel = 'tm-hybrid-lab-dolr02-01'

param dnsTtl = 30

param monitorProtocol = 'HTTP'
param monitorPort = 80
param monitorPath = '/'

param probeInterval = 30
param probeTimeout = 10
param toleratedFailures = 3

param azurePublicIpName = 'pip-dev-eus-lb-01'
