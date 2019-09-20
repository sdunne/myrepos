output "ip" {
  value = "${aws_instance.bastion1.public_ip}"
}
