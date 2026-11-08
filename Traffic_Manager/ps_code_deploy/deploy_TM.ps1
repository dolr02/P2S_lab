$rg = "rg-p2s-lab"
$template = "$PSScriptRoot/../bicep/main.bicep"
$params = "$PSScriptRoot/../bicep/main.bicepparam"

az deployment group validate `
    --resource-group $rg `
    --template-file $template `
    --parameters $params `
    --output none

if ($LASTEXITCODE -eq 0) {
    az deployment group create `
        --name "deploy-traffic-manager" `
        --resource-group $rg `
        --template-file $template `
        --parameters $params `
        --query properties.provisioningState `
        --output tsv
} else {
    Write-Host "Validace selhala. Nasazení se nespustilo."
}