This folder contains modular Bicep templates responsible for deploying the core Azure networking layer used in the P2S (Point‑to‑Site) lab environment. The modules follow Azure best practices for network segmentation, reusability, and environment isolation.

What These Modules Deploy

-------------------------------------------------------------------
- DEV VNet (vnet-dev.bicep) Creates a dedicated DEV virtual network

Deploys: App subnet GatewaySubnet (required for P2S VPN Gateway)
Outputs: VNet ID App Subnet ID GatewaySubnet ID

--------------------------------------------------------------------
- TST VNet (vnet-tst.bicep) Creates an isolated TST virtual network
Deploys: App subnet
Outputs: VNet ID App Subnet ID

main.bicep Calls both modules
Passes parameters Returns combined outputs for downstream modules (VMs, NICs, NSGs, Gateway)
