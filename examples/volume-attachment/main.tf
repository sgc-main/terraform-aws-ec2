
terraform {
  backend "s3" {}
}

module "vpc_presets" {
  source   = "sgc-main/vpc-presets/aws"
  vpc_name = lookup(var.vpc_presets, "VpcName")
  subnets  = lookup(var.vpc_presets, "SubnetNames")
  ami_name = lookup(var.vpc_presets, "AmiName")
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.prefix}-lnx-${var.env}"
  description = "${var.prefix}-lnx-${var.env}"
  vpc_id      = module.vpc_presets.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
  tags                = var.tags
}

module "iam-1" {
  source = "sgc-main/ec2-iam/aws"

  server_prefix       = var.server_prefix
  attach_ssm_policies = true
  tags                = var.tags
}

module "ec2-1" {
  source = "sgc-main/ec2/aws"

  instance_count         = var.instance_count
  server_prefix          = var.server_prefix
  server_suffix          = var.server_suffix
  ami                    = module.vpc_presets.ami_id
  instance_type          = var.instance_type
  subnet_ids             = module.vpc_presets.subnet_ids

  iam_instance_profile   = module.iam-1.iam_instance_profile_id
  vpc_security_group_ids = [module.security_group.security_group_id]
  key_name               = var.key_name
  enable_qualys          = var.enable_qualys

  tags = var.tags
}

data "aws_route53_zone" "r53-zone-1" {
  name         = var.dns_zone
  private_zone = var.is_private_zone
}
resource "aws_route53_record" "r53-record-1" {
  count              = var.instance_count
  zone_id            = data.aws_route53_zone.r53-zone-1.zone_id
  name               = module.ec2-1.instance_hostnames[count.index]
  type               = "A"
  ttl                = "60"
  records            = [module.ec2-1.private_ip[count.index]]
}
