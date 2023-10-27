output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the main VPC"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnets[*].id
  description = "The IDs of the private subnets"
}

output "security_group_ids" {
  value       = aws_security_group.allow_all[*].id
  description = "The IDs of the security groups"
}

