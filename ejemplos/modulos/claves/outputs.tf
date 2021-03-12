output clave_privada {
    value = tls_private_key.key.private_key_pem
}

output clave_publica {
    value = tls_private_key.key.public_key_pem
}