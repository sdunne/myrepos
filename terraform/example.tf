variable "key_name" {
  description = "name of AWS key pair"
}
variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/home/sdunne/.aws/credentials"
  profile                 = "redhat"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.10.0.0/16"
  tags {
    Owner = "sdunne@redhat.com"
    Name = "sdunne-vpc1"
  }
}

resource "aws_subnet" "default" {
  vpc_id                    = "${aws_vpc.default.id}"
  cidr_block                = "10.10.1.0/24"
  map_public_ip_on_launch   = true
  tags {
    Name = "sdunne-sub1"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags {
    Name = "sdunne-igw1"
  }
}

resource "aws_security_group" "access" {
  name        = "sdunne_sg_bastion"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "example" {
  ami           = "ami-0af6f794ec2d5ff13"
  instance_type = "t2.small"

  key_name  = "${var.key_name}"

  subnet_id = "${aws_subnet.default.id}"

  vpc_security_group_ids = ["${aws_security_group.access.id}"]

  tags {
    Owner = "sdunne@redhat.com"
    Name = "sdunne-bastion1"
  }
}
