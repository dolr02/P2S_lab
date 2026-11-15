$rg = "rg-p2s-lab"
$template = "$PSScriptRoot/../bicep/TM_performance.bicep"

az deployment group validate `
    --resource-group $rg `
    --template-file $template `
    --output none

if ($LASTEXITCODE -ne 0) {
    throw "Validace Performance TM selhala."
}

az deployment group create `
    --name "deploy-tm-performance" `
    --resource-group $rg `
    --template-file $template `
    --query properties.outputs `
    --output json

if ($LASTEXITCODE -ne 0) {
    throw "Nasazení Performance TM selhalo."
}