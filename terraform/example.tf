provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "/home/sdunne/.aws/credentials"
  profile                 = "redhat"
}

resource "aws_instance" "example" {
  ami           = "ami-0af6f794ec2d5ff13"
  instance_type = "t2.small"
}
