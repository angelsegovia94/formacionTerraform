variable "cidr_vpc" {
    description = "CIDR de la VPC"
    type = string
}
variable "instance_tenancy" {
    description = "Infra dedicada o no"
    type = string
    default = "default"
}
variable "nombre_vpc" {
    description = "Nombre de la VPC"
    type = string
}

variable "subnets" {
    description = "Subnets"
    type = list(map(string))
}

# subnets =list(map(string))

# [
#   {
#     subnet_name
#     subnet_az_name=null
#     subnet_az_id=null
#     subnet_cidr_block
#     subnet_public=false
#   },
#   {
#     subnet_name
#     subnet_az_name=null
#     subnet_az_id=null
#     subnet_cidr_block
#     subnet_public=false
#   }
# ]