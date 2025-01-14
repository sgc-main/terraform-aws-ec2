output "ids" {
  description = "List of IDs of instances"
  value       = module.ec2-1.id
}

output "tags" {
  description = "List of tags"
  value       = module.ec2-1.tags
}

output "instance_id" {
  description = "EC2 individual instance ID"
  value       = module.ec2-1.id[0]
}

output "credit_specification" {
  description = "Credit specification of EC2 instance (empty list for not t2 instance types)"
  value       = module.ec2-1.credit_specification
}
