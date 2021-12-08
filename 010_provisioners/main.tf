terraform {
  backend "remote" {
    organization = "jayaws"

    workspaces {
      name = "provisioners"
    }
  }

}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEO4EOVV1+36Oks1P8GFlBAycvpI3drWB2geQ1ACA2cOlR7zivnbf0QjPYz0nK/z9SNCxyrRxb44QWLmJeLjqMDPUdeJwa3cuSyMp7OOp5E6ANDfMRsrrLLxZMpNYqjy5RX9GJP6/+Vo19UllMm/uFuIXK06xdJrZSltmTsQ0Yqif3DmB+lKpXYYcCyDpY7NPOkzufMrg7rKVSPUDTHPmP8fnEEecM6+9fDWHxtlxlAdfkaV60+UPspmSpYpgsenluA7zxYAK4RuHqX5rqCS3Nj8KIIHVhpXdQZWgHHS/AYfWKqb5t1YXJafaVxn+EXo+ceRuqB+RoKJCPvaURiqb9wi27PAHV1UBiPbUcipu96v/cH3UD6tiboErlbQ35VFkUZN7BwR6+rb89AYgvuaddQiLhefKDTK3WzdLvBe9fx6mD7+t/QB/a64znvf3CtUCnGbOfsur2n6cmGnq9/rYL6Et5F7Uu0qD9E8fwgggUKN2rDJRBgSiwX2A5djJOb/E= jayarajsivadasan@pop-os"
}
resource "aws_instance" "aws_ec2_instance" {

  ami                    = "ami-083654bd07b5da81d"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_aws_ec2_instance.id]
  user_data              = data.template_file.user_data.rendered
  tags = {
    Name        = "010_provisioners_example_01"
    Description = "Provisioned by Terraform. No delete"
    ModifiedBy  = "Jayaraj"
  }
}

data "aws_vpc" "main" {
  id = "vpc-0c515a71dff3c3c39"
}
data "template_file" "user_data" {
  template = file("./userdata.yaml")
}

resource "aws_security_group" "sg_aws_ec2_instance" {
  name        = "sg_aws_ec2_instance"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress = [{
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
    },
    {
      description      = "HTTPS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },

    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["76.230.152.51/32"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }

  tags = {
    Name = "allow_http/s"
  }
}

output "public_ip" {
  value = aws_instance.aws_ec2_instance
}
