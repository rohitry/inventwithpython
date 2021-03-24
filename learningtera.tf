# Configure the AWS Provider

provider "aws" {
  region = "ap-south-1"
  access_key = "*******"
  secret_key = "*******"
}

#create a vpc
resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "testingvpc"
  }
}

#create an internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.first-vpc.id

  tags = {
    Name = "learning gateway"
  }
}


#create an custom route table

resource "aws_route_table" "learningroutetable" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main"
  }
}

#create a subnet
resource "aws_subnet" "testsubnet1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone ="ap-south-1a"

  tags = {
    Name = "learning1"
  }
}

#Associate subnet with route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.testsubnet1.id
  route_table_id = aws_route_table.learningroutetable.id
}

#Setting up of AWS security group

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allowweb"
  }
}

#creating a network interface with an ip in the subnet

resource "aws_network_interface" "webserver" {
  subnet_id       = aws_subnet.testsubnet1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_tls.id]


}

# Assign an elastic ip to the to the network

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.webserver.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

#launch an ubuntu server
resource "aws_instance" "launching-server" {
  ami           = "ami-0d758c1134823146a" # us-west-2
  instance_type = "t2.micro"
  availability_zone ="ap-south-1a"
  key_name = "yourkeypair name"

  network_interface {
    network_interface_id = aws_network_interface.webserver.id
    device_index         = 0
  }
 #to setup the network interface
  

  user_data = <<-EOF
            put in the details of the files which you wish to install.
            EOF


}




