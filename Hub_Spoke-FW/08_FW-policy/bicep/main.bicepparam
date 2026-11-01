using './main.bicep'

param location = 'eastus'
param firewallPolicyName = 'fw-policy-hub-eus-01'
param ruleCollectionGroupName = 'rcg-hubspoke-01'

param vm1PrivateIp = '10.1.1.4'
param vm2PrivateIp = '10.2.1.4'
