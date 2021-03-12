terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc #- (Required) The CIDR block for the VPC.
  instance_tenancy     = var.instance_tenancy #- (Optional) A tenancy option for instances launched into the VPC. Default is default, which makes your instances shared on the host. Using either of the other options (dedicated or host) costs at least $2/hr.
  
  enable_dns_support   = true #- (Optional) A boolean flag to enable/disable DNS support in the VPC. Defaults true.
  enable_dns_hostnames = true #- (Optional) A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false.
  
  tags = {
    Name               = var.nombre_vpc
  }#- (Optional) A map of tags to assign to the resource.
}

resource "aws_subnet" "subnet" {
  count = length(var.subnets)
  availability_zone =  var.subnets[count.index].subnet_az_name  #- (Optional) The AZ for the subnet.
  availability_zone_id = var.subnets[count.index].subnet_az_id #- (Optional) The AZ ID of the subnet.
  cidr_block = var.subnets[count.index].subnet_cidr_block#- (Required) The CIDR block for the subnet.
  vpc_id = aws_vpc.vpc.id #- (Required) The VPC ID.
  
  
  map_public_ip_on_launch = var.subnets[count.index].subnet_public #- (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
  
  
  tags = {
    Name = var.subnets[count.index].subnet_name
    
  }#- (Optional) A map of tags to assign to the resource.
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.nombre_vpc}_gateway"
  }
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.nombre_vpc}_rt"
  }
}

resource "aws_route" "route" {
  route_table_id             = aws_route_table.rt.id
  destination_cidr_block     = "0.0.0.0/0"
  gateway_id                 = aws_internet_gateway.gw.id
  
}

resource "aws_route_table_association" "connect_subnets" {
  count = length(aws_subnet.subnet)
  subnet_id = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rt.id
  
}

#8080
#3306
#22


locals  { 

  ingress =       {
                        "http": {
                                  "from_port": 8080
                                  "to_port": 8080
                                  "protocol": "tcp"
                                  "cidr_blocks": ["0.0.0.0/0"]
                              },
                        "mariadb": {
                                  "from_port": 3306
                                  "to_port": 3306
                                  "protocol": "tcp"
                                  "cidr_blocks": [var.cidr_vpc]
                               },
                        "ssh": {
                                  "from_port": 22
                                  "to_port": 22
                                  "protocol": "tcp"
                                  "cidr_blocks": ["0.0.0.0/0"] 
                               }
                    }
}

resource "aws_security_group" "sg" {
  name        = "${var.nombre_vpc}_sg"

  
  dynamic "ingress" {
    iterator = ingress_actual
    for_each = local.ingress
    
    content {
      from_port   = ingress_actual.value["from_port"]
      to_port     = ingress_actual.value["to_port"]
      protocol    = ingress_actual.value["protocol"]
      cidr_blocks = ingress_actual.value["cidr_blocks"] #["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.nombre_vpc}_sg"
  }
}