resource "aws_vpc" "test_task" {
    cidr_block           = "10.0.0.0/16"

    tags                 = {
      name               = "test_task"
    }
}

resource "aws_subnet" "private" {
    vpc_id               = aws_vpc.test_task.id
    cidr_block           = "10.0.1.0/24"
    availability_zone    = "us-east-1a"

    tags                 = {
      "name"             = "private"
    }
}
resource "aws_launch_template" "template_asg_ec2" {
    name                   = "template_asg_ec2"
    image_id               = data.aws_ami.amazonlunux.id
    instance_type          = "t3.micro"
    vpc_security_group_ids = [ aws_security_group.private.id ]
}

resource "aws_autoscaling_group" "asg_ec2" {
    name                 = "${var.base_name}-ASG"
    desired_capacity     = var.instance_count
    max_size             = 10
    min_size             = 1
    vpc_zone_identifier  = [aws_subnet.private.id]
    launch_template {
      id                 = aws_launch_template.template_asg_ec2.id
    }
}

resource "aws_security_group" "private" {
    name                 = "private"
    description          = "allow inbound/outbond traffic"
    vpc_id               = aws_vpc.test_task.id

    ingress {
      description        = "SSH for private subnet"
      from_port          = 22
      to_port            = 22
      protocol           = "tcp"
      cidr_blocks        = [aws_subnet.private.cidr_block]
    } 

    egress {
      from_port          = 0
      to_port            = 0
      protocol           = "-1"
      cidr_blocks        = [aws_subnet.private.cidr_block]
  }

    tags                 = {
      "name"             = "private"
    }
}