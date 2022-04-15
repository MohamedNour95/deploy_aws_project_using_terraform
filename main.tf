# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable availability_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}

# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name =  "${var.env_prefix}-vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

# Create a route table for my vpc
resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  
  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.env_prefix}-gw"
  }
}

# Craete route table association for subnet
resource "aws_route_table_association" "my-rta" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id  
}

# Create security group to allow ssh and web traffic
resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  #description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    #ssh  
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip] #my current ip
  }

  ingress {
    #web 
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids  = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {  
  most_recent      = true  
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# to validate the image before usage
#output "image-validation" {
#    value = data.aws_ami.latest-amazon-linux-image.id
#}

#make amazon create a private key for an exist public key on my machine
resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location) #make terraform read the key from existing file
}

resource "aws_instance" "my-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = resource.aws_key_pair.ssh-key.key_name #we can use also a key i have created before
  user_data = file("entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}

output "server-ip" {
    value = aws_instance.my-server.public_ip
}
