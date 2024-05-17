# create a service on the cloud - launch an EC2 instance on AWS
# NEVER HARDOCODE THE KEYS
# MUST NOT PUSH ANYTHING TO GITHUB UNTIL WE HAVE CREATED A .gitignore FILE TOGETHER
# which part of AWS - which region
provider "aws" {

  region = var.region

}


provider "github" {

  token = var.GITHUB_TOKEN

}

resource "aws_vpc" "tech258-martin-vpc" {
  cidr_block = var.cidr_block_vpc
  tags = {
    Name = var.vpc_name_tag
  }
}



resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.tech258-martin-vpc.id
  cidr_block        = var.cidr_block_public_subnet 
  availability_zone = var.region-az  
  tags = {
    Name = var.public_subnet_name_tag 
  }
}



resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.tech258-martin-vpc.id
  cidr_block        = var.cidr_block_private_subnet 
  availability_zone = var.region-az   
  tags = {
    Name = var.private_subnet_name_tag  # Name your private subnet here
  }
}



resource "aws_security_group" "tech258-martin_sg_terraform" {
  name        = var.security_group_name_tag
  description = "Allow inbound traffic on ports 22, 80, and 3000"

  vpc_id = aws_vpc.tech258-martin-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# which service/resource/s - ec2
resource "aws_instance" "app_instance" {
  # which type of instance - ami
  ami = var.app_ami_id
  # t2.micro
  subnet_id = aws_subnet.public_subnet.id
  instance_type = "t2.micro"
  # associate public ip with this instance
  associate_public_ip_address = true

  key_name = var.public_key
  vpc_security_group_ids = [aws_security_group.tech258-martin_sg_terraform.id]

  tags = {
    Name = var.ec2_name
  }
}


resource "github_repository" "automated_repo" {
  name        = var.repo_name
  description = "terraform repo"
  visibility  = "public"  # Change to "private" if needed
}