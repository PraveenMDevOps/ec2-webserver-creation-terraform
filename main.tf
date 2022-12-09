# Importing Key pair

resource "aws_key_pair" "mykey" {
  key_name   = "${var.project_name}-key"
  public_key = file("mykey.pub")

  tags = {
    Name     = "${var.project_name}-key"
    Project  = var.project_name
  }
}

# Creating Security Group for http and https access

resource "aws_security_group" "webserver" {
  name_prefix = "webserver"
  description = "Allow 80 and 443 traffics"

  ingress {
    description      = ""
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = ""
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name     = "${var.project_name}-webserver"
    Project  = var.project_name
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Creating Security Group for ssh access

resource "aws_security_group" "remote" {
  name        = "remote"
  description = "Allow ssh access"

  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name     = "${var.project_name}-remote"
    Project  = var.project_name
  }
}

# Creating EC2 using userdata saved in the local drive

resource "aws_instance" "webserver" {
  ami                       = var.instance_ami
  instance_type             = var.instance_type
  key_name		    = aws_key_pair.mykey.id
  vpc_security_group_ids    = [ aws_security_group.webserver.id, aws_security_group.remote.id ]
  user_data		    = file("userdata.sh")

  tags = {
    Name     = "${var.project_name}-webserver"
    Project  = var.project_name
  }
}
