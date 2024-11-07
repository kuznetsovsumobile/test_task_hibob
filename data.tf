data "aws_ami" "amazonlunux" {
  most_recent = true

  filter {
    name      = "name"
    values    = ["amzn2-ami-kernel-*"]
  }

  filter {
    name      = "virtualization-type"
    values    = ["hvm"]
  }
}