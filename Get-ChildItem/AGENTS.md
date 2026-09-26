# Agents Guidance for P2S_lab

## What this repository is

This repo contains Azure lab scenarios for VPN, networking, storage, and load balancing using Azure Bicep and Azure CLI deployment scripts.

Primary contents:
- `*/bicep/` folders: Azure Bicep templates for each lab scenario
- `*/ps_code_deploy/` and `LoadBalancer(StandardSKU)/ps_deploy/`: deployment helper scripts using `az deployment group create` and `az group create`
- `*/Screenshots/`: documentation screenshots for lab setup and validation

## Key scenario folders

- `Vnets/`: VNet/subnet deployment and RG creation scripts
- `LoadBalancer(StandardSKU)/`: Azure Standard Load Balancer deployment
- `Private_endpoint/`: private endpoint Bicep deployment
- `Service_endpoint/`: service endpoint storage/container Bicep deployment
- `VM/`: VM and nested module deployment
- `VPN_GTW/`: VPN gateway and certificate support
- `VPN_Radius_auth/`, `VPNClient_EntraID_auth/`: VPN authentication labs
- `Connection_verify/`: verification workflows

## Deployment pattern

There is no single root build/test pipeline. Use the per-lab scripts in each folder to deploy templates.

Typical commands:
- `az group create --name <rg> --location <location>` from `Vnets/ps_code_deploy/PS_create_RG`
- `az deployment group create --resource-group <rg> --template-file <template>` from a scenario folder

Examples found in the repo:
- `LoadBalancer(StandardSKU)/ps_deploy/ps_deploy_LB`
- `Private_endpoint/ps_code_deploy/ps_PE_deploy`
- `Service_endpoint/ps_code_deploy/ps_storage_deploy`
- `Vnets/ps_code_deploy/PS_create_Vnets&Subnets`
- `VM/ps_code_deploy/PS_code_deploy`

## Important conventions

- Most Bicep templates live under the scenario-specific `bicep/` folder.
- Deployment scripts are generally PowerShell wrappers around `az` CLI commands.
- The repo uses explicit template deployment rather than a centralized CI/CD setup.
- Many `README.md` files are empty or minimal; the real logic is in the Bicep and script files.

## How to be productive here

- Start by opening the scenario folder and its `bicep` files.
- When updating or refactoring, preserve the existing deployment script names and template references.
- Avoid assuming a single build/test command; validate by reading `ps_code_deploy` or `ps_deploy` scripts.
- Use `az deployment group create` syntax from the scripts as the deployment pattern.

## Notes for AI agents

- Do not add new root-level build tools unless the user asks for a repository-wide deployment structure.
- Prefer small, local edits to existing Bicep files and scripts rather than broad restructuring.
- If asked to add documentation, link to the specific folder containing the scenario rather than inventing a global README.
