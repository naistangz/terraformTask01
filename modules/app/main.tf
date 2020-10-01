provider "aws" {
  region = var.region
}

# Generate private key
resource "tls_private_key""default" {
  # Encrypted handshake, creating public and private keys
  algorithm = "RSA"
  rsa_bits = 4096

}
# AWS Key Pairs
resource "aws_key_pair" "auth" {
  key_name = var.key_name
  public_key = tls_private_key.default.public_key_openssh
//  public_key = var.public_key
}

# AWS VPC
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = {
    Name = "VPC.AndDigital.Tang"
  }
}

# AWS Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "IGW.AndDigital.Tang"
  }
}

# Granting the VPC Internet Access on its main route
resource "aws_route" "internet_access" {
  route_table_id = aws_vpc.default.main_route_table_id
  destination_cidr_block = var.destination_cidr_block
  gateway_id = aws_internet_gateway.default.id
}

# Creating subnet to launch web app instance
resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "Subnet.AndDigital.Private.Tang"
  }
}

# Creating a security group for the Load Balancer so it is accessible via the web app instance
resource "aws_security_group" "elb_default" {
  vpc_id = aws_vpc.default.id
  description = "Security Group for Load Balancer"

  # HTTP access from anywhere
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # Outbound internet access
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    Name = "SG.ELB.AndDigital"
  }
}

# Creating a security Group to access instances over SSH and HTTP
resource "aws_security_group" "default" {
  name = "webapp.A.SG"
  description = "Security Group for instances, allowing SSH traffic and HTTP"
  vpc_id = aws_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port = 0
    protocol = ""
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from VPC
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = var.vpc_cidr
  }

  # Outbound internet access
  egress {
    from_port = 0
    protocol = ""
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS Elastic Load Balancer
resource "aws_elb" "default" {
  name = "default-elb"
  subnets = [aws_subnet.public_subnet.id]
  security_groups = [aws_security_group.elb_default.id]

//  # ELB attachments
//  number_of_instances = 2
//  instances = aws_instance.web_app1[count.index]

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }
}

# AWS Private Route Table
resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "PrivateRouteTable.AndDigital.Tang"
  }
}

#  AWS Public Route Table
resource "aws_route_table" "public" {
  count = length(var.public_subnet_cidr_blocks)
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "PublicRouteTable.AndDigital.Tang"
  }
}


# EC2 Instance A with Nginx as Web Server Installed
resource "aws_instance" "web_app1" {
  instance_type = var.instance_type
  ami = var.amiapp
  key_name = aws_key_pair.auth.key_name
  availability_zone = var.availabilityZone1a
  associate_public_ip_address = true

  # Subnet attachment
  subnet_id = aws_subnet.public_subnet.id

  # Installing nginx as web server, by default this will run on port 80
  provisioner "remote-exec" {
    inline = [
    "sudo apt-get -y update",
    "sudo apt-get -y install nginx",
    "sudo service nginx start",
    ]
  }
  tags = {
    Name = "webapp1.AndDigital.Tang"
  }
}

# Second EC2 Instance
resource "aws_instance" "web_app2" {
  instance_type = var.instance_type
  ami = var.amiapp
  availability_zone = var.availabilityZone1b
  key_name = aws_key_pair.auth.key_name
  associate_public_ip_address = true

  # Subnet attachment
  subnet_id = aws_subnet.public_subnet.id

}
# Attaching instances to elastic load balancer
resource "aws_elb_attachment" "default" {
  count = 2
  elb = aws_elb.default.id
  instance = "${element(list("${aws_instance.web_app1.id}", "${aws_instance.web_app2.id}"), count.index)}"
}
