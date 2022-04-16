# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name =  "${var.env_prefix}-vpc"
  }
}

module "subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.my-vpc.id
}

module "webserver" {
  source = "./modules/webserver"
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  public_key_location = var.public_key_location
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  vpc_id = aws_vpc.my-vpc.id
  subnet_id = module.subnet.subnet.id
}