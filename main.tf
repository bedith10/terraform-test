terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
}


provider "aws" {
  region     = "us-east-1" 
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "VPC"
  }
}

//resource "aws_subnet" "Pri-subnet" {
//  vpc_id     = aws_vpc.VPC.id
//  cidr_block = "10.0.1.0/24"

//  tags = {
//    Name = "Pri-subnet"
//  }
//}

resource "aws_subnet" "Pu-subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Pu-subnet"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}



resource "aws_route_table" "RT-PU" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "RT-PU"
  }
}


resource "aws_route_table_association" "RTA" {
  subnet_id      = aws_subnet.Pu-subnet.id
  route_table_id = aws_route_table.RT-PU.id
}

//resource "aws_route_table_association" "" {
//  gateway_id     = aws_internet_gateway.foo.id
//  route_table_id = aws_route_table.bar.id
//}


resource "aws_security_group" "sg_aws" {
  name        = "sg1"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  
}

resource "aws_instance" "ec2_aws" {
  ami           = "ami-024fc608af8f886bc" 
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Pu-subnet.id
  vpc_security_group_ids    =  [aws_security_group.sg_aws.id]

  tags = {
    Name = "nginx"
  }

  }







