variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"  
}

variable "common_tags" {
  type = map 
  default = {
    Project = "Expense"
    Environment = "Dev"
    Terraform = "true"
  }
  
}

variable "description" {
  default = "Security Group for Expense Application"
}