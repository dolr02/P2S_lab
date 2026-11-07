$rg = "rg-p2s-lab"
$template = "./main.bicep"
$params = "./main.bicepparam"

az deployment group validate --resource-group $rg --template-file $template --parameters $params

if ($LASTEXITCODE -eq 0) {
    az deployment group create --resource-group $rg --template-file $template --parameters $params
} else {
    Write-Host "Validace selhala. Nasazení se nespustilo."
}