locals {
  id                                 = try(aws_instance.this.*.id, aws_spot_instance_request.this.*.id, [])
  arn                                = try(aws_instance.this.*.arn, aws_spot_instance_request.this.*.arn, [])
  capacity_reservation_specification = try(aws_instance.this.*.capacity_reservation_specification, aws_spot_instance_request.this.*.capacity_reservation_specification, "")
  instance_state                     = try(aws_instance.this.*.instance_state, aws_spot_instance_request.this.*.instance_state, [])
  outpost_arn                        = try(aws_instance.this.*.outpost_arn, aws_spot_instance_request.this.*.outpost_arn, [])
  password_data                      = try(aws_instance.this.*.password_data, aws_spot_instance_request.this.*.password_data, [])
  availability_zone                  = try(aws_instance.this.*.availability_zone, aws_spot_instance_request.this.*.availability_zone, [])
  key_name                           = try(aws_instance.this.*.key_name, aws_spot_instance_request.this.*.key_name, [])
  public_dns                         = try(aws_instance.this.*.public_dns, aws_spot_instance_request.this.*.public_dns, [])
  public_ip                          = try(aws_instance.this.*.public_ip, aws_spot_instance_request.this.*.public_ip, [])
  primary_network_interface_id       = try(aws_instance.this.*.primary_network_interface_id, aws_spot_instance_request.this.*.primary_network_interface_id, [])
  private_dns                        = try(aws_instance.this.*.private_dns, aws_spot_instance_request.this.*.private_dns, [])
  private_ip                         = try(aws_instance.this.*.private_ip, aws_spot_instance_request.this.*.private_ip, [])
  ipv6_addresses                     = try(aws_instance.this.*.ipv6_addresses, [])
  security_groups                    = try(aws_instance.this.*.security_groups, aws_spot_instance_request.this.*.security_groups, [])
  vpc_security_group_ids             = try(aws_instance.this.*.vpc_security_group_ids, aws_spot_instance_request.this.*.vpc_security_group_ids, [])
  subnet_id                          = try(aws_instance.this.*.subnet_id, aws_spot_instance_request.this.*.subnet_id, [])
  credit_specification               = try(aws_instance.this.*.credit_specification, aws_spot_instance_request.this.*.credit_specification, [])
  tags                               = try(aws_instance.this.*.tags, aws_spot_instance_request.this.*.tags, [])
  tags_all                           = try(aws_instance.this.*.tags_all, aws_spot_instance_request.this.*.tags_all, {})
  spot_bid_status                    = try(aws_spot_instance_request.this.*.spot_bid_status, [])
  spot_request_state                 = try(aws_spot_instance_request.this.*.spot_request_state, [])
  spot_instance_id                   = try(aws_spot_instance_request.this.*.spot_instance_id, [])
}

output "instance_hostnames" {
  description = "List of IDs of instances"
  value       = local.instance_hostnames
}

output "id" {
  description = "List of IDs of instances"
  value       = local.id
}

output "arn" {
  description = "List of ARNs of instances"
  value       = local.arn
}

output "capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = local.capacity_reservation_specification
}

output "instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = local.instance_state
}

output "outpost_arn" {
  description = "The ARN of the Outpost the instance is assigned to"
  value       = local.outpost_arn
}

output "password_data" {
  description = "Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for instances running Microsoft Windows. This attribute is only exported if `get_password_data` is true"
  value       = local.password_data
}

output "availability_zone" {
  description = "List of availability zones of instances"
  value       = local.availability_zone
}

// GH issue: https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/issues/8
//output "placement_group" {
//  description = "List of placement groups of instances"
//  value       = ["${element(concat(aws_instance.this.*.placement_group, list("", []), 0)}"]
//}

output "key_name" {
  description = "List of key names of instances"
  value       = local.key_name
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = local.public_dns
}

output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = local.public_ip
}

output "primary_network_interface_id" {
  description = "List of IDs of the primary network interface of instances"
  value       = local.primary_network_interface_id
}

output "private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = local.private_dns
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = local.private_ip
}

output "ipv6_addresses" {
  description = "The IPv6 address assigned to the instance, if applicable."
  value       = local.ipv6_addresses
}

output "security_groups" {
  description = "List of associated security groups of instances"
  value       = local.security_groups
}

output "vpc_security_group_ids" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = local.vpc_security_group_ids
}

output "subnet_id" {
  description = "List of IDs of VPC subnets of instances"
  value       = local.subnet_id
}

output "credit_specification" {
  description = "List of credit specification of instances"
  value       = local.credit_specification
}

output "tags" {
  description = "List of tags of instances"
  value       = local.tags
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = local.tags_all
}

output "spot_bid_status" {
  description = "The current bid status of the Spot Instance Request"
  value       = local.spot_bid_status
}

output "spot_request_state" {
  description = "The current request state of the Spot Instance Request"
  value       = local.spot_request_state
}

output "spot_instance_id" {
  description = "The Instance ID (if any) that is currently fulfilling the Spot Instance request"
  value       = local.spot_instance_id
}
