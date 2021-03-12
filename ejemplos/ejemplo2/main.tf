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
    
    provisioner "remote-exec" {
        inline = [ "sudo apt-get update && sudo apt-get install python -y" ]
    }
    provisioner "local-exec" {
        command =  "echo \"${self.public_ip} ansible_connection=ssh ansible_port=22 ansible_user=ubuntu ansible_ssh_private_key_file=./clave_privada.pem\" > inventario.ini"
    }
    
    provisioner "local-exec" {
        command =  "ansible-playbook -i inventario.ini mi-playbook.yaml"
    }
    
    # connection {
    #     type        = "ssh"
    #     host        = self.public_ip
    #     user        = "ubuntu"
    #     private_key = tls_private_key.angel_key.private_key_pem
    #     port        = 22
    # }
    
    # provisioner "remote-exec" {
    #     inline = [
    #         "docker run -p 8080:8080 -d bitnami/tomcat"
    #     ]
    # }
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


