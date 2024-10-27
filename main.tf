provider "aws" {
  region = "us-east-1"  # aws configuration get region
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "My_VPC"
  }
}

# Subnets
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  

  tags = {
    Name = "Public_Subnet_1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"  

  tags = {
    Name = "Public_Subnet_2"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private_Subnet_1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private_Subnet_2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main_Internet_Gateway"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public_Route_Table"
  }
}

# Associate Route Tables with Public Subnets
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Groups
# Security Group for Windows Server in Public Subnet 1
resource "aws_security_group" "sg_windows" {
  vpc_id = aws_vpc.main.id

  # Allow RDP from anywhere
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_Windows_Public"
  }
}

# Security Group for Ubuntu Server in Public Subnet 2
resource "aws_security_group" "sg_ubuntu" {
  vpc_id = aws_vpc.main.id

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_Ubuntu_Public"
  }
}

# Security Group for Private Subnet 1
resource "aws_security_group" "sg_private1" {
  vpc_id = aws_vpc.main.id

  # Allow HTTP within VPC
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_Private_1"
  }
}

# Security Group for Private Subnet 2
resource "aws_security_group" "sg_private2" {
    vpc_id = aws_vpc.main.id

    # Allow HTTP within VPC
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

      tags = {
        Name = "SG_Private_2"
    }
}

# Windows Server Instance in Public Subnet 1
resource "aws_instance" "windows_server" {
    ami           = "ami-0324a83b82023f0b3"  
    instance_type = "t2.micro"                
    subnet_id     = aws_subnet.public_subnet1.id
    vpc_security_group_ids = [aws_security_group.sg_windows.id] 
    tags = {
        Name = "Windows_Server"
    }
}

# Ubuntu Server Instance in Public Subnet 2
resource "aws_instance" "ubuntu_server" {
    ami           = "ami-0866a3c8686eaeeba"  
    instance_type = "t2.micro"                
    subnet_id     = aws_subnet.public_subnet2.id
    vpc_security_group_ids = [aws_security_group.sg_ubuntu.id] 

    tags = {
        Name = "Ubuntu_Server"
    }
}
