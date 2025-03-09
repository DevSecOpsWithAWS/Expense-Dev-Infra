#expence-dev-mysql
resource "aws_security_group" "allow_tls" {
  name        = local.sg_final_name
  description = var.description
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    var.common_tags,
    {
        Name = local.sg_final_name
    }
  )
}

