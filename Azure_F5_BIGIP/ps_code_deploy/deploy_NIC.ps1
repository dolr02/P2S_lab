param(
    [switch]$Deploy
)

$templateFile = Join-Path $PSScriptRoot '../bicep/NIC.bicep'

if (-not (Test-Path -LiteralPath $templateFile -PathType Leaf)) {
    throw "Bicep šablona nebyla nalezena: $templateFile"
}

$deploymentArgs = @(
    '--resource-group', 'rg-p2s-lab'
    '--name', 'f5-nics'
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