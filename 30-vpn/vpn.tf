resource "aws_key_pair" "openvpnas" {
  key_name   = "openvpnas"
  public_key = file("C:\\Users\\choud\\openvpnas.pub")
}

resource "aws_instance" "openvpn" {
  ami = data.aws_ami.openvpn.id
  key_name = aws_key_pair.openvpnas.key_name
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  instance_type = "t2.micro"
  subnet_id = local.public_subnet_id
  user_data = file("user-data.sh")
  tags = {
    Name = "${var.project_name}-${var.environment}-vpn"
  }
}

#C:\Users\choud

output "vpn_public_ip" {
  value = aws_instance.openvpn.public_ip  
}