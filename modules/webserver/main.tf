
# Create security group to allow ssh and web traffic
resource "aws_security_group" "my-sg" {
  name        = "my-sg"
  #description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

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
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = resource.aws_key_pair.ssh-key.key_name #we can use also a key i have created before
  user_data = file("./modules/webserver/entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-server"
  }
}