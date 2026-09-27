using './main.bicep'

param location = 'eastus'

param sharedKey = readEnvironmentVariable('SHARED_KEY', '')
