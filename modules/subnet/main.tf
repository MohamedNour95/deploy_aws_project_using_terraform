# Create a Subnet
resource "aws_subnet" "my-subnet" {
  vpc_id     = var.vpc_id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

# Create a route table for my vpc
resource "aws_route_table" "my-route-table" {
  vpc_id = var.vpc_id

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
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-gw"
  }
}

# Craete route table association for subnet
resource "aws_route_table_association" "my-rta" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id  
}