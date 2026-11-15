$rg = "rg-p2s-lab"
$template = "$PSScriptRoot/../bicep/neu-network.bicep"

az deployment group validate `
    --resource-group $rg `
    --template-file $template `
    --output none

if ($LASTEXITCODE -ne 0) {
    throw "Validace sítě selhala. Nasazení se nespustilo."
}

az deployment group create `
    --name "deploy-weu-network" `
    --resource-group $rg `
    --template-file $template `
    --query properties.outputs `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Nasazení sítě selhalo."
}