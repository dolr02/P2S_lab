# 1) SMAZAT všechny staré root certy v CurrentUser\My
Get-ChildItem Cert:\CurrentUser\My |
  Where-Object { $_.Subject -eq "CN=P2SRootCert" } |
  Remove-Item -Force

# 2) SMAZAT všechny staré client certy v CurrentUser\My
Get-ChildItem Cert:\CurrentUser\My |
  Where-Object { $_.Subject -eq "CN=P2SClientCert" } |
  Remove-Item -Force

# 3) Vytvořit nový ROOT cert s private key
$root = New-SelfSignedCertificate `
  -Type Custom `
  -KeySpec Signature `
  -Subject "CN=P2SRootCert" `
  -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 `
  -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -KeyUsageProperty Sign `
  -KeyUsage CertSign

# 4) Export public části root certu pro Azure
Export-Certificate -Cert $root -FilePath "$env:USERPROFILE\root.cer" | Out-Null

# 5) Vytvořit CLIENT cert podepsaný rootem
$client = New-SelfSignedCertificate `
  -Type Custom `
  -DnsName "P2SClientCert" `
  -Subject "CN=P2SClientCert" `
  -KeySpec Signature `
  -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 `
  -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -Signer $root `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

# 6) Export CLIENT certu do PFX
$pwd = ConvertTo-SecureString -String "Heslo123!" -AsPlainText -Force
Export-PfxCertificate -Cert $client -FilePath "$env:USERPROFILE\P2SClient.pfx" -Password $pwd | Out-Null

Write-Host "Hotovo. root.cer a P2SClient.pfx jsou v $env:USERPROFILE"
