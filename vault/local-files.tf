resource "local_file" "tls-certificate" {
  filename = "./certificate.pem"
}

resource "local_file" "tls-key" {
  filename = "./key.pem"
}

resource "local_file" "ca-chain" {
  filename = "./ca-chain.pem"
}

