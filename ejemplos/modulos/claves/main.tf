terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        tls = {
            source ="hashicorp/tls"
        }
    }
}

provider "tls" {}


resource "aws_key_pair" "key_pair" {
  key_name   = var.id_clave
  public_key = tls_private_key.key.public_key_openssh
  
  
}

resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = var.longitud_clave_rsa
    
    provisioner "local-exec" {
         command = "echo \"${self.private_key_pem}\" > ${var.id_clave}_priv.pem && echo \"${self.public_key_pem}\" > ${var.id_clave}_pub.pem"
     }
     
    provisioner "local-exec" {
        command = "chmod 700 ${var.id_clave}_priv.pem"
    }

    provisioner "local-exec" {
        command = "chmod 700 ${var.id_clave}_pub.pem"
    }
}  