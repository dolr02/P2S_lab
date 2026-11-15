# Traffic Manager Lab — Deployment Guide

## Workflow

1. Prepare Bicep and deployment scripts in VS Code.
2. Commit and push to GitHub.
3. Pull the repository in Azure Cloud Shell.
4. Deploy using Azure CLI from PowerShell.

## Deployment order

Prerequisite: East US VNet and subnet already exist.

| Order | Component | Bicep file |
| --- | --- | --- |
| 1 | East US Load Balancer | `LoadBalancer/bicep/LB_bicep.bicep` |
| 2 | East US VM1 + VM2 | `LoadBalancer/bicep/VMs_LB.bicep` |
| 3 | On-prem network | `Traffic_Manager/bicep/onprem-network.bicep` |
| 4 | On-prem VM + Nginx | `Traffic_Manager/bicep/onprem-web.bicep` |
| 5 | North Europe network | `Traffic_Manager/bicep/neu-network.bicep` |
| 6 | North Europe VM + Nginx | `Traffic_Manager/bicep/VM_web_neu.bicep` |
| 7 | Child Performance Traffic Manager | `Traffic_Manager/bicep/TM_performance.bicep` |
| 8 | Parent Priority Traffic Manager | `Traffic_Manager/bicep/main.bicep` |

`VMs_LB.bicep` calls the `VM_Vnet.bicep` module for each East US VM.

Deploy each network before its VM.
Both Azure web endpoints must exist before deploying the Performance profile.
Deploy the child Performance profile before the parent Priority profile.

Parent TM parameters are stored in `main.bicepparam`.

## North Europe deployment

| Order | Component | Deployment script |
| --- | --- | --- |
| 1 | North Europe network | `Traffic_Manager/ps_code_deploy/deploy_neu_network.ps1` |
| 2 | North Europe VM + Nginx | `Traffic_Manager/ps_code_deploy/deploy_VM_web_neu.ps1` |
| 3 | Child Performance TM | `Traffic_Manager/ps_code_deploy/deploy_TM_performance.ps1` |
| 4 | Parent Priority TM | `Traffic_Manager/ps_code_deploy/deploy_TM.ps1` |

Run the scripts in Azure Cloud Shell — PowerShell after pulling the repository.

West Europe was initially planned, but Azure rejected new resources
for this subscription. The second regional endpoint was deployed
in North Europe instead.

## Current routing

| Profile | Method | Endpoints |
| --- | --- | --- |
| `tm-hybrid-lab` | Priority | Nested Azure group; on-prem fallback |
| `tm-performance-lab` | Performance | East US LB; North Europe VM |

The parent nested endpoint uses `minChildEndpoints = 1`.

- Both Azure regions healthy: Performance selects a region.
- One Azure region unavailable: the other region serves requests.
- Both Azure regions unavailable: the parent selects on-prem.

Traffic Manager selects destinations through DNS.
HTTP traffic goes directly to the selected endpoint.

## Client entry point

`tm-hybrid-lab-dolr02-01.trafficmanager.net`

Use this parent hostname to test the complete routing hierarchy.

The child hostname is
`tm-performance-lab-dolr02-01.trafficmanager.net`.
It selects between Azure regions and has no on-prem fallback.

## Regional endpoints

| Branch | Public IP | Web servers |
| --- | --- | --- |
| East US | `52.240.54.161` | LB → `vm-web-eus-01` / `vm-web-eus-02` |
| North Europe | `20.234.16.168` | `vm-web-neu-01` |
| Simulated on-prem | `20.127.32.104` | `vm-onprem-web-01` |

## Validation and troubleshooting

- Both East US backends were verified through the LB.
- North Europe was verified through its public IP and DNS name.
- Nested parent and child endpoint health was verified.
- North Europe web failure triggered selection of East US.
- North Europe recovery returned both regional endpoints Online.

Individual procedures and recorded results are documented
in troubleshooting issues 01–04.

## Planned work

- Test failure of both Azure web branches and fallback to on-prem.
- Add Geographic routing.
- Extend troubleshooting for the new configuration.

MultiValue is excluded from the planned work.
S2S VPN is not deployed.