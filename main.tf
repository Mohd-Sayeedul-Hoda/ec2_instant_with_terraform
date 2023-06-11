resource "aws_vpc" "terra_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraf_vpc_public"
  }
}

resource "aws_subnet" "terra_public_subnet" {
  vpc_id                  = aws_vpc.terra_vpc.id
  cidr_block              = "10.123.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "terra_subnet_public"
  }
}

resource "aws_internet_gateway" "terra_gateway" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "terra_gateway_public"
  }
}

resource "aws_route_table" "terra_route" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "terra_route_public"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.terra_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.terra_gateway.id
}

resource "aws_route_table_association" "route_association" {
  subnet_id      = aws_subnet.terra_public_subnet.id
  route_table_id = aws_route_table.terra_route.id
}

resource "aws_security_group" "terra_sg" {
  name        = "dev_sg"
  description = "deb security group"
  vpc_id      = aws_vpc.terra_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_key_pair" "terra_auth" {
  key_name = "terra_key"
  public_key = file("~/.ssh/terrakey.pub")
}

resource "aws_instance" "terra_instant" {
  instance_type = "t2.micro"
  ami =data.aws_ami.server_ami.id
  key_name = aws_key_pair.terra_auth.id
    vpc_security_group_ids = [aws_security_group.terra_sg.id]
    subnet_id = aws_subnet.terra_public_subnet.id
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }
    tags={
    Name = "terra_instant_public"
  }
    
}