provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/home/sdunne/.aws/credentials"
  profile                 = "redhat"
}

resource "aws_instance" "example" {
  ami           = "ami-0af6f794ec2d5ff13"
  instance_type = "t2.small"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}
