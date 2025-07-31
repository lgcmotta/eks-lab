output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for sn in values(aws_subnet.public) : sn.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for sn in values(aws_subnet.private) : sn.id]
}
