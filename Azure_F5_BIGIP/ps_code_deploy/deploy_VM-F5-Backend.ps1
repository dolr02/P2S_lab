param(
    [Parameter(Mandatory)]
    [string]$SshPublicKeyPath,

    [switch]$Deploy
)

$templateFile = Join-Path $PSScriptRoot '../bicep/VM-F5-Backend.bicep'

if (-not (Test-Path -LiteralPath $templateFile -PathType Leaf)) {
    throw "Bicep šablona nebyla nalezena: $templateFile"
}

if (-not (Test-Path -LiteralPath $SshPublicKeyPath -PathType Leaf)) {
    throw "Soubor s veřejným SSH klíčem nebyl nalezen: $SshPublicKeyPath"
}

$sshPublicKey = (Get-Content -LiteralPath $SshPublicKeyPath -Raw).Trim()

$deploymentArgs = @(
    '--resource-group', 'rg-p2s-lab'
    '--name', 'f5-backend-vm'
    '--template-file', $templateFile
    '--parameters', 'location=eastus', "sshPublicKey=$sshPublicKey"
)

if ($Deploy) {
    az deployment group create @deploymentArgs
} else {
    az deployment group what-if @deploymentArgs
}

if ($LASTEXITCODE -ne 0) {
    throw "Azure CLI skončilo s kódem $LASTEXITCODE."
}