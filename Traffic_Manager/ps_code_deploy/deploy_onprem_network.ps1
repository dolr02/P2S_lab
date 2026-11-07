$rg = "rg-p2s-lab"
$template = "$PSScriptRoot/../bicep/onprem-network.bicep"

az deployment group validate `
    --resource-group $rg `
    --template-file $template `
    --output none

if ($LASTEXITCODE -eq 0) {
    az deployment group create `
        --name "deploy-onprem-network" `
        --resource-group $rg `
        --template-file $template `
        --query properties.provisioningState `
        --output tsv
} else {
    Write-Host "Validace selhala. Nasazení se nespustilo."
}