resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"

tags = {
    Name = "${var.client_name}-vpc"
    Managed_by = "${var.client_name}"
  }
}
#Internat Gateway :
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags = {
    Name = "${var.client_name}-IGW"
    Managed_by = "${var.Managed_by}"
  }
}
#public subnet
resource "aws_subnet" "pubSB-1" {
  vpc_id     = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "${var.client_name}-public-subnet"
    Managed_by = "${var.Managed_by}"
  }
}

#private Subnet
resource "aws_subnet" "privSB-1" {
  vpc_id     = "${aws_vpc.my-vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "${var.client_name}-private-subnet"
    Managed_by = "${var.Managed_by}"
  }
}

#public Route Table
resource "aws_route_table" "Pub-RT" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "${var.client_name}-pub-Route"
    Managed_by = "${var.Managed_by}"
  }
}
resource "aws_route_table" "Pri-RT" {
  vpc_id = "${aws_vpc.my-vpc.id}"

  tags = {
    Name = "${var.client_name}-pri-Route"
    Managed_by = "${var.Managed_by}"
  }
}
#public subnet association :
resource "aws_route_table_association" "publicroute" {
  subnet_id      = aws_subnet.pubSB-1.id
  route_table_id = aws_route_table.Pub-RT.id
}
#private subnet association :
resource "aws_route_table_association" "privateroute" {
  subnet_id      = aws_subnet.privSB-1.id
  route_table_id = aws_route_table.Pri-RT.id
}
#security Group :
resource "aws_security_group" "Sg" {
  name        = "${var.client_name}-Sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.my-vpc.id}"

ingress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/16"]
}
ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/16"]
}
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_instance" "web1" {
  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pubSB-1.id
  key_name      = "new"

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.Sg.id
  ]

  tags = {
    Name        = "${var.client_name}-webserver1"
    Managed_by = var.Managed_by
  }
}


output "my_web_server1" {
  value = aws_instance.web1.public_ip
}

resource "aws_instance" "web2" {
  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pubSB-1.id
  key_name      = "new"

  vpc_security_group_ids = [
    aws_security_group.Sg.id
  ]

  tags = {
    Name        = "${var.client_name}-privateserver1"
    Managed_by = var.Managed_by
  }
}


output "web2_private_ip" {
  description = "Private IP address of web2 EC2 instance"
  value       = aws_instance.web2.private_ip
}
