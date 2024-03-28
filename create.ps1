$params = @{
  DnsName = "Your Root Cert"
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
  DnsName = "yourdomain.org"
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
# if you want to silence the cert warnings on other systems you'll need to import the rootCA.crt on them too
Export-Certificate -Cert $rootCA -FilePath "C:\certs\rootCA.crt"
Export-Certificate -Cert $newCert -FilePath "C:\certs\newcert.crt"
Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root' -FilePath "C:\certs\rootCA.crt"

Export-PfxCertificate -Cert $newCert -FilePath 'C:\certs\newcert.pfx' -Password (ConvertTo-SecureString -AsPlainText 'YOUR_SECRET_PASSWORD' -Force)

# convert root ca certificate to pem format
openssl x509 -inform DER -in rootCA.crt -out rootCA.pem

# export server private key to pem format
openssl pkcs12 -in newcert.pfx -nocerts -nodes -out newcertkey.pem -passin pass:YOUR_SECRET_PASSWORD

# convert server certificate to pem format
openssl x509 -inform DER -in newcert.crt -out newcert.pem
