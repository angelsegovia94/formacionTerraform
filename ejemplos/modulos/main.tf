terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = var.region_aws
    profile = "default"
}

# module "claves" {
#     source = "./claves"
#     longitud_clave_rsa = 4096
#     id_clave = var.id_clave
# }

# module "instancia" {
#     source = "./instancia"

# }

module "red" {
    source = "./red"
    nombre_vpc  = "AngelVPC" 
    cidr_vpc    = "10.10.0.0/16"
    subnets     = [
                      {
                        "subnet_name": "angel-public"
                        "subnet_az_name": null
                        "subnet_az_id": null
                        "subnet_cidr_block": "10.10.1.0/24"
                        "subnet_public":true
                      },
                      {
                        "subnet_name":"angel-private"
                        "subnet_az_name": null
                        "subnet_az_id": null
                        "subnet_cidr_block":"10.10.2.0/24"
                        "subnet_public":false
                      }
                  ]
}