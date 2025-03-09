module "vpc" {
  #source = "../AWS_VPC_TERRAFORM"
  source = "git::https://github.com/DevSecOpsWithAWS/AWS_VPC_TERRAFORM.git?ref=main"
  cidr_block = var.vpc_cidr_block
  project_name = var.project_name
  environment = var.environment
  common_tags = var.common_tags
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  database_subnet_cidr = var.database_subnet_cidr
  is_peering_required = true
}

resource "aws_db_subnet_group" "expense" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = module.vpc.database_subnet_id
tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}