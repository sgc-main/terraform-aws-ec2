variable vpc_presets {
  type = map
  default = {
    AmiName     = "Ubuntu*"
    VpcName     = "vpc-1"
    SubnetNames = "subnet-1,subnet-2"
  }
}
variable tags {
  type = map
  default = {
      ProjectName    = "Test EC2"
      Environment    = "POC"
      Classification = "INF"
  }
}
variable instance_count  { default = 1 } 
variable instance_type   { default = "t3.medium" }
variable prefix          { default = "ons" }
variable env             { default = "sbx" }
variable server_prefix   { default = "testserver" } 
variable server_suffix   { default = "poc.com" } 
variable enable_qualys   { default = "true" }
variable key_name        { default = "" }
variable dns_zone        { default = "poc.com" }
variable is_private_zone { default = "true" }

