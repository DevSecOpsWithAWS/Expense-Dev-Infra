resource "aws_instance" "allow_tls" {
  ami = "ami-09c813fb71547fc4f"
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type = "t2.micro"
  subnet_id = local.public_subnet_id
  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
  }
}