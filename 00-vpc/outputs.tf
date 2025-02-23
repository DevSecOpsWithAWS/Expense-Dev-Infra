# output "azs_info" {
#   value = module.vpc.azs_info
# }

# output "subnet_info" {
#   value = module.vpc.subnet_info
# }

# output "vpc_id" {
#   value = aws_vpc.expense_vpc.id
  
# }
#  output "public_subnet_id" {
#   value = aws_subnet.public[*].id
#  }

#   output "private_subnet_id" {
#   value = aws_subnet.private[*].id
#  }

#   output "database_subnet_id" {
#   value = aws_subnet.database[*].id
#  }

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
  
}