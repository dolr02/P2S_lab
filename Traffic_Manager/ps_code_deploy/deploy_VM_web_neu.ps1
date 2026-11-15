$rg = "rg-p2s-lab"
$template = "$PSScriptRoot/../bicep/VM_web_neu.bicep"
$password = Read-Host "Heslo správce North Europe VM" -MaskInput

try {
    az deployment group validate `
        --resource-group $rg `
        --template-file $template `
        --parameters adminPassword=$password `
        --output none

    if ($LASTEXITCODE -ne 0) {
        throw "Validace VM selhala. Nasazení se nespustilo."
    }

    az deployment group create `
        --name "deploy-vm-web-weu" `
        --resource-group $rg `
        --template-file $template `
        --parameters adminPassword=$password `
        --query properties.outputs `
        --output json

    if ($LASTEXITCODE -ne 0) {
        throw "Nasazení VM selhalo."
    }
} finally {
    Remove-Variable password -ErrorAction SilentlyContinue
}