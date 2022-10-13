resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Terraform-Project"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  depends_on = [aws_vpc.main]

  tags = {
    Name = "Public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  depends_on = [aws_vpc.main]

  tags = {
    Name = "Private"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-igw"
  }
}

resource "aws_eip" "natgw-ip" {
  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw-ip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "Terraform-natgw"
  }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
  tags = {
    Name = "Public"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Private"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "tls_private_key" "terraform" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform" {
  key_name   = "terraform-key"
  public_key = tls_private_key.terraform.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.terraform.private_key_pem
  sensitive = true
}

data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "bastion-host" {
  ami                         = data.aws_ami.app_ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  key_name                    = "terraform-key"
  security_groups             = ["${aws_security_group.bastion.id}"]
  depends_on                  = [aws_security_group.bastion]
  tags = {
    Name = "terraform-bastion-host"
  }
}

resource "aws_instance" "private-instances" {
  ami             = data.aws_ami.app_ami.id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private.id
  key_name        = "terraform-key"
  security_groups = ["${aws_security_group.private_instances.id}"]
  depends_on      = [aws_security_group.private_instances]
  count           = 2
  tags = {
    Name = var.private_instances_names[count.index]
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow SSH traffic from the internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "bastion_security_group" {
  value = aws_security_group.bastion.id
}

resource "aws_security_group" "private_instances" {
  name        = "private"
  description = "Allow SSH traffic from Bastion Host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = -1
  }
}
