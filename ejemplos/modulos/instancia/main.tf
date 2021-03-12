terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

data "aws_ami" "ami_ubuntu" {
  most_recent      = true
  owners           = var.owners

  filter {
    name   = "name"
    values = var.names_filter #["*ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values =  var.virtualization_type_filter #["hvm"]
  }
}

resource "aws_instance" "mi-maquina-angel" {
    ami = data.aws_ami.ami_ubuntu.id
    instance_type = var.instance_type
    key_name = var.key_pair_name
    
    
    tags = {
        Name = var.instance_name
    }
    
}

resource "aws_ebs_volume" "angel_volume2" {
  availability_zone = aws_instance.mi-maquina-angel.availability_zone
  size              = var.volume_size

  tags = {
    Name = "${aws_instance.mi-maquina-angel.tags.Name}_vol2"
  }
}

resource "aws_volume_attachment" "angel_volume2_att" {
  device_name = var.device_name #"/dev/sdh"
  volume_id   = aws_ebs_volume.angel_volume2.id
  instance_id = aws_instance.mi-maquina-angel.id
}