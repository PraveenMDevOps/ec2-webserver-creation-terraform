# Creating ec2 with apache server using terraform by importing custom key pair

## Features
- Easy to customize and deploy.
- Deploy static webpage.

## Prerequisites for this project
- IAM user with programmatic access.
- Locally created ssh key pairs.
- Terraform should be installed locally.

## Setting up Terraform in the local machine
- Please click [here](https://developer.hashicorp.com/terraform/downloads) to get knowledge on how to install Terraform.

## Creating Terraform Configurations

### Create a file variable.tf
```sh
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "project_name" {}
variable "instance_ami" {}
variable "instance_type" {}
```

### Create a provider.tf file 
```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```

### Create a setup.sh file as userdata to configure HTTP server and a static webpage
```sh
#!/bin/bash

yum install httpd php -y

cat <<EOF > /var/www/html/index.php
<?php
echo "<h1><center>Hello! World!</center></h1>"
?>
EOF

systemctl restart httpd.service
systemctl enable httpd.service
```

Go to the local directory to save the tfstate files and initiate the Terraform working directory using the below command.

```
terraform init
```

Let us create the main.tf file as below.

> To import the public key to AWS setup

```
resource "aws_key_pair" "mykey" {
  key_name   = "${var.project_name}-key"
  public_key = file("mykey.pub")

  tags = {
    Name     = "${var.project_name}-key"
    Project  = var.project_name
  }
}
```

> To create the Security Group for HTTP and HTTPS access for webserver

```
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
```

> To create the Security Group for SSH access

```
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
```

> To Create EC2 using userdata saved in the local drive

```
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
```

#### Lets validate the terraform files using
```sh
terraform validate
```
#### Lets plan the architecture and verify once again.
```sh
terraform plan
```
#### Lets apply the above architecture to the AWS.
```sh
terraform apply
```
