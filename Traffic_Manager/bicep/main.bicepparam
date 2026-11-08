using './main.bicep'

param profileName = 'tm-hybrid-lab'
param dnsLabel = 'tm-hybrid-lab-dolr02-01'

// DNS cache: 30 sekund.
param dnsTtl = 30

// Kontrola HTTP služby.
param monitorProtocol = 'HTTP'
param monitorPort = 80
param monitorPath = '/'

// Standardní interval sond a timeout.
param probeInterval = 30
param probeTimeout = 10
param toleratedFailures = 3

// Primární endpoint — priorita 1.
param azurePublicIpName = 'pip-dev-eus-lb-01'

// Záložní endpoint — priorita 2.
param onpremFqdn = 'onprem-kjpwu2bkc3vsk.eastus.cloudapp.azure.com'
