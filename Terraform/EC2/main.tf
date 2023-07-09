locals {
  ami_id = data.aws_ami.amznlx2.id
  ports  = [80, 443, 53, 23, 3389, 22, 50, 60, 70]
}

## VPC
resource "aws_vpc" "web_server_vpc" {
  cidr_block           = "20.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    "Owner"   = title("john")
    "Name"    = upper("hello")
    "ENV"     = lower(var.app)
    "Datadog" = join("_", [var.web, var.app])
    "Regions" = lookup({ us = "us-east-1", eu = "eu-east1", name1 = "heodore", name2 = "Jack" }, "name3", "aps-east-1")
  }
}

## Public Subnet
resource "aws_subnet" "public_subnet" {
  cidr_block        = "20.0.1.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "Public Subnet"
  }
}

## Private Subnet
resource "aws_subnet" "private_subnet" {
  cidr_block        = "20.0.2.0/24"
  vpc_id            = aws_vpc.web_server_vpc.id
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "Private Subnet"
  }
}


## Internet Gateway
resource "aws_internet_gateway" "web_server_ig" {
  vpc_id = aws_vpc.web_server_vpc.id
  tags = {
    "Name" = "web_server_internet_gateway"
  }
}

## Route Table
resource "aws_route_table" "web_server_rt" {
  vpc_id = aws_vpc.web_server_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_server_ig.id
  }
  tags = {
    "Name" = "Public Route Table"
  }
}

## Route Table ASS
resource "aws_route_table_association" "web_server_ass" {
  route_table_id = aws_route_table.web_server_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

## Security group
resource "aws_security_group" "web_server_sg" {
  name        = "web_server_sg"
  description = "Allow 80 and 22 ports into web server"
  vpc_id      = aws_vpc.web_server_vpc.id

  dynamic "ingress" {
    for_each = local.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_server_sg"
  }
}

## EC2
resource "aws_instance" "web_server" {
  ami                         = local.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.web_server_sg.id]
  key_name                    = "jenkins-key"
  user_data                   = file("userdata")
}
