terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.87.0"
    }
  }
  backend "s3"{
    bucket = "sridevsecops-dev"
    key = "Expense-project-infra-dev-rds"
    region = "us-east-1"
    dynamodb_table = "sridevsecops-dev-tb"
	
}
}


provider "aws" {
  # Configuration options
  region = "us-east-1"
}