$rg = "rg-p2s-lab"

foreach ($vm in @("vm-web-eus-01", "vm-web-eus-02")) {
    $result = az vm run-command invoke `
        --resource-group $rg `
        --name $vm `
        --command-id RunShellScript `
        --scripts 'if systemctl is-active --quiet nginx; then echo "WEB_ACTIVE"; else echo "WEB_INACTIVE"; fi' `
        --query "value[].message" `
        --output tsv

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$vm : UNKNOWN"
    } elseif (($result -join "`n") -match "WEB_INACTIVE") {
        Write-Host "$vm : INACTIVE"
    } elseif (($result -join "`n") -match "WEB_ACTIVE") {
        Write-Host "$vm : ACTIVE"
    } else {
        Write-Host "$vm : UNKNOWN"
    }
}