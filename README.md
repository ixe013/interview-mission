# Secret Mission

This is the code to acheive a mission given by an undisclosed (aka secret) company, as part of their interview process

# Deploy Vault

Followed the [Vault on Kubernetes Deployment Guide](https://learn.hashicorp.com/tutorials/vault/kubernetes-raft-deployment-guide?in=vault/kubernetes)

## Create fundamental secrets

These are the secrets Vault needs to run

### Auto-unseal
```
export AWS_ACCESS_KEY_ID=AKIASXY2YF56RKE5HY72
read -s -p "Enter the secret access key for $AWS_ACCESS_KEY_ID: " AWS_SECRET_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY

kubectl create secret generic eks-creds --from-literal=AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID?}" --from-literal=AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY?}"
```

### Private key and certificate

Private key management is always hard. This private key would be generated and saved in an manually managed PKI. 

```
openssl x509 -out vault/certificate.pem << EOF
-----BEGIN CERTIFICATE-----
MIIEfjCCAmagAwIBAgIBBDANBgkqhkiG9w0BAQsFADAeMRwwGgYDVQQLExNpc3N1
ZXIucGFyYWxpbnQuY29tMB4XDTIxMDcyMTA1MDAwMFoXDTIyMDcyMTA1MDAwMFow
OTE3MDUGA1UEAxMudmF1bHQtMC52YXVsdC1pbnRlcm5hbC52YXVsdC5zdmMuY2x1
c3Rlci5sb2NhbDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMGoGt3o
jqTFBG7FrdPQrdP184t8rdKUodW8Dn1Q/5dXbr7fPqp+6VjxUIZW5tB90YOWpHeH
RLguFWZQw849d8EWlGK7fFn1L6dhfG4oCL4t5SebgRB3NJA6nLdLNFzC82a3hQ7Z
pue5ri5G9rSo9r5AmSd7nD73PBq66iaThSof90tdRciYG1JjT7PrTMfuHSoZ6D0u
hbnw3jh6VRSKwrEBd/b5RwR4i/Gg3zY/kUteCchkidgPrv+OhAnShitmCbNbEL0w
B8u5xE9wGpX3RW1MCv60k946aFkFq1nbehwKBnDlaxenvHZVsohi0TG+KCfDTT4m
kxUMIxJ03dy9cVcCAwEAAaOBqzCBqDAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBSu
7hDokFXyZJNktfSwdt9azhfBQDALBgNVHQ8EBAMCBeAwEQYJYIZIAYb4QgEBBAQD
AgZAMB4GCWCGSAGG+EIBDQQRFg94Y2EgY2VydGlmaWNhdGUwOQYDVR0RBDIwMIIu
dmF1bHQtMC52YXVsdC1pbnRlcm5hbC52YXVsdC5zdmMuY2x1c3Rlci5sb2NhbDAN
BgkqhkiG9w0BAQsFAAOCAgEAmZ+HoqgviXwc3WUvBRxdofxP7Cwm9Y8plu6Xa4+C
277yTZ8PJ4qL0lqSRjCekczibWtiAkJP5MV/ldbrYyWuQQv3+r7v2rNicJL1L5TZ
bd2Ihz86oxQS6vYe1usHiBVEWQaDtW53U1oBzRDH4aOxl+PLt3v66whaau5j1t4S
/tfSwvj6UzdaO6C3F4fsXZAi9qGMY11axRVfJAKGI0u2MOcffokNa2vLQlbBtyOX
AtoCi6Kt6PaALLEpf9opMpvXyUxGUIqHq1p41AYIFBP5H3PcyHcEmXyVaLsnMtA8
03/KP1H8TfRnrTLLNVSuVoITsm3eLWJgWe45JFYAyK0S4SZwO37/Yv+4NPddL69G
OGkudvcYTirEV1MBtdSyzSNVZK3n0+dBBh0vASPcmCD6g4cXX6Afnyruf84WFlSP
HPg7CeR8InBDoQfz0IMYRRvnd1FDqYBj/tRBEJqkzI8YfDXALRa+DdzoMf+h5LJg
aRMtg2CXrsi4Y7VaPrdYoIr4HzFnLfMFTdon1kFQAwr9RDrhIpjD8bMUTpkbfAPY
q3DepH7EKy1IZ+nShAO92YLYVFui0meyYvk+6ia2C7xe9g5jBpZCJ/0Kl96h/68o
zuULLest4smuuUjSNQrUn38sy1L7z9XHtRKreiL5W6u2mDfOM78cLCFRhw1ekQMm
e38=
-----END CERTIFICATE-----
EOF

openssl rsa -out vault/key.pem << EOF
-----BEGIN RSA PRIVATE KEY-----
key here...
-----END RSA PRIVATE KEY-----
EOF

kubectl --namespace=vault create secret tls tls-server --cert vault/certificate.pem --key vault/key.pem
```

## Certificate chain required for Vault nodes to talk to themselves
```
openssl x509 -out vault/ca-chain.pem << EOF
-----BEGIN CERTIFICATE-----
MIIFITCCAwmgAwIBAgIBATANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDEw9jYS5w
YXJhbGludC5jb20wHhcNMjEwNzE5MDMxNzAwWhcNMzEwNzE5MDMxNzAwWjAaMRgw
FgYDVQQDEw9jYS5wYXJhbGludC5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
ggIKAoICAQDlcKH6DbmyYjOf4s5/T9NtFqU9N8VXnQL3ANzfcjkK+bptnfn5ZfWm
L9Zrva2I8NzshXf77RKfmndpwcGmQzgdPq7dsyw62HueY8LjmoSjqSCVk2aNENZx
VHtcB+DublDaEGjaL1FfqjNzlTaohKumQYb4aamK02NB+ajOpJLfcGic3A2KgeIC
+tQNNVEXBTnBLOTFExjomFMdTqoSl4Bw1HTuhA4cOIhZF4zHaCaGvYAhaUO1hlaW
TlsmK64ComeBRIeeNOQHv5Q/dyQYPbUcZJZJvDzvrZmdPKi5aEJVp89siLKfSykM
jafN9oBhDNDeU+3/GW8U07KfZYK0ESxtXcPnvX6oN9GCEzbvLzJDAlRg2pjcCrek
v2OktkMqz/lIfdGVrDfu/Ot05eZXvoeg/YHnWYo5CQ8729wJu28Ygyu4sKIpGHY+
L0ubH1k6b/re3urUeGQjGw+JuFMoBJoo1N6s5eX4Pxzjjdny1oTcyysEYL2CSoM4
ad9CaYYzupXbSjKU6WmKEOX5HMwOQ5QMpnBZNklBnt5qwHgnl3PetvDXuv3SJsNS
FeKWUV7ImbWKlO166R6KEFp0jVZP2HUeaznlo0ujCU1yd48I9Xr9IazlvNvYoKti
YGPOLUGJlPOo8wUmhwWConErI52B6yedj09IV6+ky2zYuKrlSoeXVwIDAQABo3Iw
cDAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRmKoy+5UH+ZM90yv+LB3EGpCWG
MjALBgNVHQ8EBAMCAQYwEQYJYIZIAYb4QgEBBAQDAgAHMB4GCWCGSAGG+EIBDQQR
Fg94Y2EgY2VydGlmaWNhdGUwDQYJKoZIhvcNAQELBQADggIBADy+nRKbhPQ1Z2ym
l2NfRoU8yIs3LaECGlzZTA+6JXst8wwd7ac0HEnEgRPvXaDr43INGnPfr6t4VGDM
Aye+uV2vvWBqZESq7eiTaog7eiz7US5YwlBDh9pffTCmJXZiHz0tAP/cH64y8CdN
4vEzaPCd7ZKlu0PTvtFhITlNoag/3/5mANlvFM6nn4CoD83/4m6gzA7OjX+Jbp6E
jBNQHTZMQHzQs4xAv3k+Jfn0ZgKkHLqjGgIZXXxfpydbE3zDL0A/xw3hR8t2yzsC
X/bV04Df89YBxLbHfCecJKO90rKKSLS/z0AI60+prw7hRZaqCfUDmaoz/+Zmeh9X
XlMYocBEAHHGYJRiXlH39eMqpfKgImnlaf/zK/G8f9GC1ykWMeJ4SQoaYysibTSk
QGY/SCY65D2lA1bgAb+KlElzpqxdjh0Qko/5CPpC4qJ9cY1nUneA7+lCFxXz3rC+
KUyyVYShq1cOZapEegOgZJEfgT9ahsQzMJPQpD4OS8zygSj9Na8z9EMDlahIMxGN
M7/Aa7Wg+pS2sXDRhfu4nrOfOMsSc3WWy7IJQWV0CGhTBfhK3UCyS5v+mtsgrLVa
rMm6r5DJPhssLcRYgkcAxKYlS9HSoyrkq/qLDB5BQv5fbzJ2ccqVSe4X0yIS6KLD
7enifGeyViIY4P+dL0SsRli6pdtz
-----END CERTIFICATE-----
EOF
openssl x509 << EOF >> vault/ca-chain.pem
-----BEGIN CERTIFICATE-----
MIIFJTCCAw2gAwIBAgIBAjANBgkqhkiG9w0BAQsFADAaMRgwFgYDVQQDEw9jYS5w
YXJhbGludC5jb20wHhcNMjEwNzE5MDMxODAwWhcNMjYwNzE5MDMxODAwWjAeMRww
GgYDVQQLExNpc3N1ZXIucGFyYWxpbnQuY29tMIICIjANBgkqhkiG9w0BAQEFAAOC
Ag8AMIICCgKCAgEA4CCJJ4JmWJWDP109wU+FwRrRj5H/hXTtkMbS65wKIbXTjF7A
UI7qVVD1tLMJaGpvdhRfE3dZAO2iGgEYwhioh+CgEAakDROhrSoL7kvoQOfppvot
RJzO07oHsKQMMu0jS6u4zZDnGw+tZwWCqZHBZ5SRcc/RyLVuMGAugeXWF5gJbkXE
EZ0yOIf+dyV0za9vUMxnmP8nfduZ7LU+ULi8KRkY/wcr2bc39uq1h1GXDvXEnzjD
HnW7+HqJBOt2qWPV1JqgjvaD/Z/5dlBmcmcEujI8CzJctUQjrpdJFMqXdgjnBQBC
eN/0+4FFIZWMDPrW0nTfyoGBtArZwG5G/fumRckxS1r+HKA36fP8pbs01HFYSXY3
GiqLo72ILrRIS8MPDz+f3xoDcmpcJrcsAyDerLhNSZ57xi+vj1yKHPShUkNwyeh+
BfXGkp4soW+WLV3dWeRAZZgNxud702Kl8rXHppc0y0a/flinvd9A9qeZF99YEEHf
w4zcNvuVggML9wXS0FRgwcoPC6Er7A9Lv7eJseAzXU2a9VVBwGZ3WIDOP43d+LpK
MeOMZniw5hLXHKd4e5xFPcV0fVIrA6/+rngIqTXcd2cQZZxMh9lR7kC6GAyE/6LZ
mcUFFzyQB34CuOeJmRu+6IQ/34bs2KJN90zZqQ+nGjUwRwOMVmub8B5ILeMCAwEA
AaNyMHAwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUPS134bs7ZGDVLrDjDd3l
u2bOyKQwCwYDVR0PBAQDAgEGMBEGCWCGSAGG+EIBAQQEAwIABzAeBglghkgBhvhC
AQ0EERYPeGNhIGNlcnRpZmljYXRlMA0GCSqGSIb3DQEBCwUAA4ICAQBMsFlIlouj
x6o7f+4cDLhA0UmpI1cOtKyoBxGovErXtY4EPE+icd/1H9epZngTIK8bJtCIt1yd
ZzrUccNAMgDmq7kCwVYxqFzVYHellNkOR2iJuMT6l5EZHFVNMtTuzFRTqtMHAbiz
IPcsj9t4r5l4mB/8JBA5IlQdSYiV8DwA600T72v+lQ3d0jAILfxf+K8iib9PGNg7
77/HDx/rsVfCC+pQtBNo2giLsCzc878PEF+E0ZQhFPpVAderdPcGrxzc1178Ufpc
c1g7icTHhZThggMM9mHINeqkFqIrD4OmLGnDmUkhPrrGOAzuqG48WJRcAhycrWmo
INpSkLCwkIsPbs9qE3gpUS5hGLiVXw+63lvhISHM8j2OpN0vj+pdP8waigiAdcC0
QJ4j/ywVPlIxxVXWcK+dqIr3qXW0o7x+acF5GwMXBIH+/Qp3pEjKGoRUD0KjEq/P
gCaYZ4RFpmQyjNfWNNQKoTTkzqirDGL6LpuXRXAIuFTmXrZIeeYqLTJPfbUVwZh3
gOLBx8yOUh1cOCrWx3Sbbh0aNKwdCvE4+Rs+9cYf1SNzELgY4FehapJBK8Yn/Ouv
kl5OOmF3pgPVRnhXw1ucd0pTIxjLiCm/PykU0YJjgikXmEIOYd+nW+xzDqONif3w
gtJCuhwYg00Q0lSG2rRCi0mUxmb4j6UgoA==
-----END CERTIFICATE-----
EOF

kubectl --namespace=vault create secret generic tls-ca --from-file vault/ca-chain.pem
```

# Deploy manually
```
helm template vault hashicorp/vault --namespace vault \
    --values vault/global.yaml \
    --values vault/service.yaml \
    --values vault/injector.yaml > vault/build.yaml
kubectl apply --filename vault/build.yaml
```

# Initialze and run
```
kubectl exec -it vault-0 -- /bin/sh -c "VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200 vault status"
kubectl exec -it vault-0 -- /bin/sh -c "VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200 vault operator init"
```

# Dynamic secrets

## Setup
```
kubectl exec -it vault-0 -- /bin/sh -c "VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200 vault secrets enable database"
kubectl exec -it vault-0 -- /bin/sh -c "VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200 vault write database/config/mysql plugin_name=mysql-database-plugin connection_url='{{username}}:{{password}}@tcp(mysql.databases.svc.cluster.local:3306)/' allowed_roles=readonly username=root password=$ROOT_PASSWORD"
kubectl exec -it vault-0 -- /bin/sh -c "VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200 vault write database/roles/readonly db_name=mysql creation_statements=\"CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';\" default_ttl=1h max_ttl=24h"
```

## Use
```
# Get the credentials
kubectl exec -it vault-0 -- /bin/sh -c "VAULT_ADDR=https://vault-0.vault-internal.vault.svc.cluster.local:8200 vault read database/creds/readonly"

# Start a container that has the mysql client
kubectl run mysql-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mysql:8.0.25-debian-10-r37 --namespace databases --command -- bash

# Login
mysql -h mysql.databases.svc.cluster.local -uv-root-readonly-V5o39qrGOnBjjBFD -p my_database
```
