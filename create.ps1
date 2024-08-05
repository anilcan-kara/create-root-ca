$params = @{
  DnsName = "Anilcan Root Cert"
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-Date).AddYears(5)
  CertStoreLocation = 'Cert:\LocalMachine\My'
  KeyUsage = 'CertSign','CRLSign' #fixes invalid cert error
}

$rootCA = New-SelfSignedCertificate @params

$params = @{
  DnsName = "anilcan.local"
  Signer = $rootCA
  KeyLength = 2048
  KeyAlgorithm = 'RSA'
  HashAlgorithm = 'SHA256'
  KeyExportPolicy = 'Exportable'
  NotAfter = (Get-date).AddYears(2)
  CertStoreLocation = 'Cert:\LocalMachine\My'
}

$newCert = New-SelfSignedCertificate @params

# Extra step needed since self-signed cannot be directly shipped to trusted root CA store
# if you want to silence the cert warnings on other systems you'll need to import the anilcan.local.root.crt on them too
Export-Certificate -Cert $rootCA -FilePath "C:\certs\anilcan.local.root.crt"
Export-Certificate -Cert $newCert -FilePath "C:\certs\anilcan.local.crt"
Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "C:\certs\anilcan.local.root.crt"

Export-PfxCertificate -Cert $newCert -FilePath 'C:\certs\anilcan.local.pfx' -Password (ConvertTo-SecureString -AsPlainText 'd3Dgd86uc' -Force)

# convert root ca certificate to pem format
openssl x509 -inform DER -in anilcan.local.root.crt -out anilcan.local.root.pem

# export server private key to pem format
openssl pkcs12 -in anilcan.local.pfx -nocerts -nodes -out anilcan.local.key.pem -passin pass:d3Dgd86uc

# convert server certificate to pem format
openssl x509 -inform DER -in anilcan.local.crt -out anilcan.local.pem
