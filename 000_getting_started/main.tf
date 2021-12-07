# module where no explicit provider instance is selected.

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Similar to variables. To DRY
locals {
  project_name = "tinytrials"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

resource "aws_instance" "aws_ec2_instance" {

  ami           = "ami-083654bd07b5da81d"
  instance_type = var.instance_type

  tags = {
    Name        = "${local.project_name}-0001"
    Description = "Provisioned by Terraform. No delete"
    ModifiedBy  = "Jayaraj"
  }
}
## When you specify a module, you need to run init first.
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1a"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# To print out data form the objects created on cloud

output "ResourceARN" {
  value = aws_instance.aws_ec2_instance.arn
}
output "PrivateIP" {
  value = aws_instance.aws_ec2_instance.private_ip
}
output "PublicIP" {
  value = aws_instance.aws_ec2_instance.public_ip
}
output "PublicDNS" {
  value = aws_instance.aws_ec2_instance.public_dns
}
