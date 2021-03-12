terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
        tls = {
            source = "hashicorp/tls"
        }
        null = {
            source = "hashicorp/null"
        }
    }
}

provider "null" {}

provider "tls" {}

provider "aws" {
    region = "eu-west-1"
    profile = "default"
}


resource "aws_key_pair" "angel_key_pair" {
  key_name   = "angel-key-pair"
  public_key = tls_private_key.angel_key.public_key_openssh
  
  
}

resource "tls_private_key" "angel_key" {
    algorithm = "RSA"
    rsa_bits = 4096
    
    provisioner "local-exec" {
         command = "echo \"${self.private_key_pem}\" > clave_privada.pem && echo \"${self.public_key_pem}\" > clave_publica.pem"
     }
     
    provisioner "local-exec" {
        command = "chmod 700 clave_privada.pem"
    }

    provisioner "local-exec" {
        command = "chmod 700 clave_publica.pem"
    }
}  


resource "aws_security_group" "sg_angel" {
  name        = "sg_angel"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_angel"
  }
}


data "aws_ami" "ami_ubuntu" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "mi-maquina-angel" {
    #ami = "ami-05573edad5dd1a926"
    ami = data.aws_ami.ami_ubuntu.id
    instance_type = "t2.micro"
    key_name = aws_key_pair.angel_key_pair.key_name
    #vpc_security_group_ids = [aws_security_group.allow_ssh_angel.id]
    security_groups = [aws_security_group.sg_angel.name]
    
    
    tags = {
        Name = "AngelEC2"
    }
    
}

resource "aws_ebs_volume" "angel_volume2" {
  availability_zone = aws_instance.mi-maquina-angel.availability_zone
  size              = 5

  tags = {
    Name = "${aws_instance.mi-maquina-angel.tags.Name}_vol2"
  }
}

resource "aws_volume_attachment" "angel_volume2_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.angel_volume2.id
  instance_id = aws_instance.mi-maquina-angel.id
}


# resource "null_resource" "guardar_claves" {
#      provisioner "local-exec" {
#          command = "echo ${tls_private_key.angel_key.private_key_pem} > clave_privada.pem && echo ${tls_private_key.angel_key.public_key_pem} > clave_publica.pem"
#      }
# }


output "angel_private_key" {
    value = tls_private_key.angel_key.private_key_pem
}


output "angel_public_key" {
    value = tls_private_key.angel_key.public_key_pem
}

output "ip_tomcat" {
    value = aws_instance.mi-maquina-angel.public_ip
}

output "dns_tomcat" {
    value = aws_instance.mi-maquina-angel.public_dns
}


