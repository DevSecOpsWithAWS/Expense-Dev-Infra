module "mysql_sg" {
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_SECURITYGROUP_TERRAFORM.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "mysql"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  description = var.description
}

module "backend_sg" {
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_SECURITYGROUP_TERRAFORM.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "backend"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  description = var.description
}

module "frontend_sg" {
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_SECURITYGROUP_TERRAFORM.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "frontend"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  description = var.description
}

module "vpn_sg" {
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_SECURITYGROUP_TERRAFORM.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "vpn"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  description = var.description
}

module "bastion_sg" {
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_SECURITYGROUP_TERRAFORM.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "bastion"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  description = var.description
}

module "app_alb_sg" {
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_SECURITYGROUP_TERRAFORM.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "app-alb"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  description = var.description
}

module "web_alb_sg" {
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_SECURITYGROUP_TERRAFORM.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_name = "web-alb"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  description = var.description
}
#app alb accepting traffice from bastion host.
resource "aws_security_group_rule" "app_alb_bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.app_alb_sg.sg_id
}

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.bastion_sg.sg_id
}

resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.vpn_sg.sg_id
}

resource "aws_security_group_rule" "vpn_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.vpn_sg.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.vpn_sg.sg_id
}
resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.vpn_sg.sg_id
}

resource "aws_security_group_rule" "app_alb_vpn" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.app_alb_sg.sg_id
}

resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "mysql_vpn" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "backend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}
resource "aws_security_group_rule" "backend_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}

resource "aws_security_group_rule" "backend_app_alb"{
  type = "ingress"
  from_port =8080
  to_port =8080
  protocol = "tcp"
  source_security_group_id = module.app_alb_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}
resource "aws_security_group_rule" "mysql_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.backend_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "web_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.web_alb_sg.sg_id
}

resource "aws_security_group_rule" "app_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.frontend_sg.sg_id
  security_group_id = module.app_alb_sg.sg_id
}

resource "aws_security_group_rule" "frontend_web_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  #cidr_blocks = ["0.0.0.0/0"]
  source_security_group_id = module.web_alb_sg.sg_id
  security_group_id = module.frontend_sg.sg_id
}

resource "aws_security_group_rule" "frontend_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.frontend_sg.sg_id
}