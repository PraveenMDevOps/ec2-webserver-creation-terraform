variable "region" {
  default = "ap-south-1"
}

variable "access_key" {
  description = "my access key"
  default     = "aws_iam_access_key"
}

variable "secret_key" {
  description = "my secret key"
  default     = "aws_iam_sectet_key"
}

variable "project_name" {
  default = "your_project_name"
}

variable "instance_ami" {
  default = "ami_id_from_aws"
}

variable "instance_type" {
  default = "t2.micro"
}
