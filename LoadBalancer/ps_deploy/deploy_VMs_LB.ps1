$rg = "rg-p2s-lab"
$template = "$PSScriptRoot/../bicep/VMs_LB.bicep"
$vmCount = 2

# Heslo se při psaní nezobrazuje a není uložené v Gitu.
$password = Read-Host "Heslo správce VM" -MaskInput

try {
    az deployment group validate `
        --resource-group $rg `
        --template-file $template `
        --parameters vmCount=$vmCount adminPassword=$password `
        --output none

    if ($LASTEXITCODE -eq 0) {
        az deployment group create `
            --name "deploy-web-vms" `
            --resource-group $rg `
            --template-file $template `
            --parameters vmCount=$vmCount adminPassword=$password `
            --query properties.provisioningState `
            --output tsv
    } else {
        Write-Host "Validace selhala. Nasazení se nespustilo."
    }
} finally {
    Remove-Variable password -ErrorAction SilentlyContinue
}