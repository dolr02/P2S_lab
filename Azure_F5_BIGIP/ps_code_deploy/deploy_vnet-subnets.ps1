param(
    [switch]$Deploy
)

$resourceGroup = 'rg-p2s-lab'
$templateFile = Join-Path $PSScriptRoot '../bicep/vnet-subnets.bicep'

if (-not (Test-Path -LiteralPath $templateFile -PathType Leaf)) {
    throw "Bicep šablona nebyla nalezena: $templateFile"
}

$deploymentArgs = @(
    '--resource-group', $resourceGroup
    '--name', 'f5-vnet-subnets'
    '--template-file', $templateFile
    '--parameters', 'location=eastus'
)

if ($Deploy) {
    az deployment group create @deploymentArgs
} else {
    az deployment group what-if @deploymentArgs
}

if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI skončilo s kódem $LASTEXITCODE."
}