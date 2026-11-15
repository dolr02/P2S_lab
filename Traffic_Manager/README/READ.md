# Traffic Manager Lab — Deployment Guide

## Workflow

1. Prepare Bicep and deployment scripts in VS Code.
2. Commit and push to GitHub.
3. Pull the repository in Azure Cloud Shell.
4. Deploy using Azure CLI from PowerShell.

## Existing lab — deployment order

Prerequisite: East US VNet and subnet already exist.

| Order | Component | Bicep file |
| --- | --- | --- |
| 1 | Azure Load Balancer | `LoadBalancer/bicep/LB_bicep.bicep` |
| 2 | Azure VM1 + VM2 | `LoadBalancer/bicep/VMs_LB.bicep` |
| 3 | On-prem network | `Traffic_Manager/bicep/onprem-network.bicep` |
| 4 | On-prem VM + Nginx | `Traffic_Manager/bicep/onprem-web.bicep` |
| 5 | Priority Traffic Manager | `Traffic_Manager/bicep/main.bicep` |

`VMs_LB.bicep` calls the `VM_Vnet.bicep` module for each Azure VM.
TM parameters are stored in `main.bicepparam`.

## Next — West Europe endpoint

| Order | Component | Bicep file |
| --- | --- | --- |
| 1 | West Europe network | `Traffic_Manager/bicep/weu-network.bicep` |
| 2 | West Europe VM + Nginx | `Traffic_Manager/bicep/VM_web_weu.bicep`|

Deploy the network before the VM. Verify the new web endpoint before adding it to a new TM profile.

The existing lab is already running. Adding West Europe does not require redeploying it.