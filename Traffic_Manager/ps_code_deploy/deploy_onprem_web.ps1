$rg = "rg-p2s-lab"
$template = "$PSScriptRoot/../bicep/onprem-web.bicep"
$password = Read-Host "Heslo správce on-prem VM" -MaskInput

try {
    az deployment group validate `
        --resource-group $rg `
        --template-file $template `
        --parameters adminPassword=$password `
        --output none

    if ($LASTEXITCODE -eq 0) {
        az deployment group create `
            --name "deploy-onprem-web" `
            --resource-group $rg `
            --template-file $template `
            --parameters adminPassword=$password `
            --query properties.outputs `
            --output json
    } else {
        Write-Host "Validace selhala. Nasazení se nespustilo."
    }
} finally {
    Remove-Variable password -ErrorAction SilentlyContinue
}