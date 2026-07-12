flowchart LR
    Client[Internet Client<br/>HTTP Request :80]

    PIP[Azure Public IP<br/>Standard SKU]

    LB[Azure Load Balancer<br/>Standard SKU<br/><br/>Frontend IP Configuration<br/>Load Balancing Rule :80<br/>Health Probe TCP :80]

    BE[Backend Pool]

    VM1[Virtual Machine 01<br/>NIC<br/>Private IP<br/><br/>Web Server<br/>Nginx :80]

    VM2[Virtual Machine 02<br/>NIC<br/>Private IP<br/><br/>Web Server<br/>Nginx :80]

    NSG[Network Security Group<br/><br/>Allow TCP 80<br/>Allow AzureLoadBalancer Probe]

    Client -->|TCP 80| PIP
    PIP --> LB
    LB -->|Load balancing rule| BE

    BE --> VM1
    BE --> VM2

    LB -.->|Health Probe TCP 80| VM1
    LB -.->|Health Probe TCP 80| VM2

    NSG -.-> VM1
    NSG -.-> VM2
    