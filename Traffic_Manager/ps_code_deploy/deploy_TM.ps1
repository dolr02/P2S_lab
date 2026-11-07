# 1. Kontrola šablony
./Traffic_Manager/ps_code_deploy/deploy.ps1 `
    -ResourceGroup "rg-traffic-manager-lab" `
    -Action validate

# 2. Náhled změn
./Traffic_Manager/ps_code_deploy/deploy.ps1 `
    -ResourceGroup "rg-traffic-manager-lab" `
    -Action what-if

# 3. Nasazení
./Traffic_Manager/ps_code_deploy/deploy.ps1 `
    -ResourceGroup "rg-traffic-manager-lab" `
    -Action deploy