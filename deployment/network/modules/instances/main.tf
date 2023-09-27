resource "aws_instance" "instance" {
  key_name = var.key_name

  count = length(var.instances)

  ami           = var.instances[count.index].ami
  instance_type = var.instances[count.index].instance_type

  associate_public_ip_address = var.instances[count.index].public_ip
  subnet_id                   = var.instances[count.index].subnet_id
  vpc_security_group_ids      = [aws_security_group.security_group[count.index].id]
  private_ip                  = var.instances[count.index].private_ip

  root_block_device {
    delete_on_termination = true
    volume_type           = "gp3"
    volume_size           = var.instances[count.index].volume_size
  }

  tags = {
    Name = "${var.name}-${var.instances[count.index].name}"
  }
}

resource "aws_security_group" "security_group" {
  count = length(var.instances)

  name        = "${var.instances[count.index].name}-security_group"
  description = "The security group for ${var.instances[count.index].name} generated by Terraform"

  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.instances[count.index].ports

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instances[count.index].name}-security_group"
  }
}
