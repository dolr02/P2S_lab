## Architecture Explanation

This lab demonstrates a route-based Site-to-Site VPN connection between a simulated on-premises network and an Azure virtual network.

The simulated on-premises environment consists of two virtual machines. The client VM (`192.168.1.5`) represents an on-premises workload, while the RRAS VM (`192.168.1.4`) acts as the on-premises VPN router.

The Azure environment contains an Azure VNet (`10.0.0.0/16`), an Azure VM (`10.0.0.4`), and an Azure VPN Gateway.

### Traffic Flow

Traffic from the on-premises client to the Azure network follows this path:

```text
192.168.1.5
    │
    │ UDR
    │ 10.0.0.0/16 → 192.168.1.4
    ▼
192.168.1.4
RRAS
    │
    │ IKEv2 / IPsec
    ▼
Azure VPN Gateway
    │
    ▼
10.0.0.4
Azure VM
```

The User Defined Route (UDR) on the simulated on-premises subnet provides the route for Azure-bound traffic. It forwards traffic destined for `10.0.0.0/16` to the RRAS router at `192.168.1.4`.

RRAS then forwards the traffic through the IKEv2/IPsec tunnel to the Azure VPN Gateway.

The Azure VPN Gateway terminates the IPsec tunnel and routes the traffic into the Azure VNet, where it reaches the destination VM.

### Role of Each Component

**On-Premises Client (`192.168.1.5`)**
Represents a workload located in the on-premises network and generates traffic destined for Azure.

**UDR**
Provides the route from the simulated on-premises subnet to the RRAS router:

`10.0.0.0/16 → 192.168.1.4`

In a real on-premises environment, this routing decision would normally be implemented by an on-premises router, Layer 3 switch, or firewall. The Azure UDR is used here to simulate that routing behavior.

**RRAS (`192.168.1.4`)**
Acts as the on-premises VPN router. It terminates the site-to-site VPN configuration and forwards traffic between the local network and the IPsec tunnel.

**IKEv2 / IPsec Tunnel**
Provides the encrypted connection between the simulated on-premises RRAS router and the Azure VPN Gateway.

**Local Network Gateway**
Represents the on-premises network from the Azure perspective. It defines the on-premises VPN endpoint and the remote address space (`192.168.1.0/24`).

**Azure VPN Gateway**
Terminates the site-to-site VPN connection on the Azure side and provides connectivity between the on-premises network and the Azure VNet.

**Azure VM (`10.0.0.4`)**
Represents a workload located inside the Azure VNet and serves as the final destination for the connectivity test.

### Routing Principle

The important concept demonstrated by this lab is that a successful VPN tunnel does not automatically guarantee end-to-end connectivity.

The VPN connection provides the encrypted path between the two networks, but routing is still required to direct traffic into that path.

In this lab:

```text
Local network:
192.168.1.0/24

Remote network:
10.0.0.0/16

VPN router:
192.168.1.4
```

Therefore, traffic destined for `10.0.0.0/16` is forwarded to the RRAS router, which sends it through the VPN
