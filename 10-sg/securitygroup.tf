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