# AWS EC2 Instance Terraform module

Terraform module which creates Linux and Windows EC2 instance(s) on AWS.  

- Instance EBS volume encryption is mandatory, by default using the `alias/aws/ebs` key that can be changed to any CMK.   
- The module supports the following build features in addition to standard EC2  attributes:
    - Iterative builds of EC2 instances by specifying `var.instance_count` and `var.server_prefix` the iterator format is defined by `var.count_format`, which can be updated.
    - By specifying `var.extended_userdata_list` during iterative builds we can introduce individual user-data script extensibility per each node built.
    - By specifying `var.instance_static_hostname` enables the support for building based on module `for_each`
    - Setting `var.create_spot_instance` to `true` and specifying spot related additional variables the module builds `Spot Instances`
    - Operating system is set by default to Linux, can be changed to Windows by setting `var.os_type` to `win`

- User-Data template provides the following features for Linux instances:
    - Finds partitions and mounts under `/data`, `/data1`, `/data[n-1]` any unused drives.
    - Requires the attachment of an IAM Role that includes `ec2:DescribeTags` permissions for successfull completion
    - Can trigger OS updates by setting `var.enable_updates` to `true`
    - Configures EC2 hostname to the same value as the `Name` tag.
    - Can be extended with custom scripting by inserting the additional script into `var.extended_userdata`

- User-Data template provides the following features for Windows instances:
    - Supports AMIs compatible with [`EC2Launch v2`](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2launch-v2.html) such as:
        - `Windows_Server-2022*`
        - `EC2LaunchV2-Windows_Server*`
    - Initializes all secondary volumes
    - Runs only once at EC2 build and any future changes are ignored
    - Configures EC2 hostname to the same value as the `Name` tag and restarts it for the name change to take effect.
    - If `var.dns_servers` list variable is set to one or two IP addresses it will set DNS on the network interface.
    - Can be extended with custom scripting by inserting the additional script into `var.extended_userdata` or `var.extended_userdata_list`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_spot_instance_request.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [aws_kms_key.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Examples

### EC2 instance with EBS volume attachment  

Configuration in this directory creates EC2 instances, EBS volume and attach it together.  
Unspecified arguments for security group id and subnet are inherited from the default VPC.  
This example outputs instance id and EBS volume id.  

main.tf
```hcl

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
```  

variables.tf
```hcl
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

```  

outputs.tf
```hcl
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
```  


## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| <a name="input_ami"></a> [ami](#input\_ami) | ID of AMI to use for the instance | `string` | n/a |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | If true, the EC2 instance will have associated public IP address | `bool` | `false` |
| <a name="input_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#input\_capacity\_reservation\_specification) | Describes an instance's Capacity Reservation targeting option | `any` | `null` |
| <a name="input_count_format"></a> [count\_format](#input\_count\_format) | Instance hostname iterative number format | `string` | `"%02d"` |
| <a name="input_cpu_credits"></a> [cpu\_credits](#input\_cpu\_credits) | The credit option for CPU usage (unlimited or standard) | `string` | `"standard"` |
| <a name="input_create_spot_instance"></a> [create\_spot\_instance](#input\_create\_spot\_instance) | Depicts if the instance is a spot instance | `bool` | `false` |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Coma separated string of DNS server IP addresses | `string` | `""` |
| <a name="input_ebs_block_device"></a> [ebs\_block\_device](#input\_ebs\_block\_device) | Additional EBS block devices to attach to the instance | `list(map(string))` | `[]` |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` |
| <a name="input_enable_partitioning"></a> [enable\_partitioning](#input\_enable\_partitioning) | Enable Partitioning | `string` | `"true"` |
| <a name="input_enable_updates"></a> [enable\_updates](#input\_enable\_updates) | Enable OS Updates | `string` | `"false"` |
| <a name="input_enable_volume_tags"></a> [enable\_volume\_tags](#input\_enable\_volume\_tags) | Whether to enable volume tags (if enabled it conflicts with root\_block\_device tags) | `bool` | `true` |
| <a name="input_enclave_options_enabled"></a> [enclave\_options\_enabled](#input\_enclave\_options\_enabled) | Whether Nitro Enclaves will be enabled on the instance. Defaults to `false` | `bool` | `null` |
| <a name="input_ephemeral_block_device"></a> [ephemeral\_block\_device](#input\_ephemeral\_block\_device) | Customize Ephemeral (also known as Instance Store) volumes on the instance | `list(map(string))` | `[]` |
| <a name="input_extended_userdata"></a> [extended\_userdata](#input\_extended\_userdata) | User-Data additional script | `string` | `""` |
| <a name="input_extended_userdata_list"></a> [extended\_userdata\_list](#input\_extended\_userdata\_list) | Userdata: Separate scripts to be executed on each VM in suite. Use-case, service cluster creation | `list` | `[]` |
| <a name="input_get_password_data"></a> [get\_password\_data](#input\_get\_password\_data) | If true, wait for password data to become available and retrieve it. | `bool` | `null` |
| <a name="input_hibernation"></a> [hibernation](#input\_hibernation) | If true, the launched EC2 instance will support hibernation | `bool` | `null` |
| <a name="input_host_id"></a> [host\_id](#input\_host\_id) | ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host | `string` | `null` |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile. | `string` | `""` |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to launch | `number` | `1` |
| <a name="input_instance_initiated_shutdown_behavior"></a> [instance\_initiated\_shutdown\_behavior](#input\_instance\_initiated\_shutdown\_behavior) | Shutdown behavior for the instance | `string` | `""` |
| <a name="input_instance_static_hostname"></a> [instance\_static\_hostname](#input\_instance\_static\_hostname) | Static hostname of the instance. To be used for single deployments or with module for\_each on a list of names | `string` | `null` |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"t3.micro"` |
| <a name="input_ipv6_address_count"></a> [ipv6\_address\_count](#input\_ipv6\_address\_count) | A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet | `number` | `null` |
| <a name="input_ipv6_addresses"></a> [ipv6\_addresses](#input\_ipv6\_addresses) | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface | `list(string)` | `null` |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The key name to use for the instance | `string` | `""` |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | ARN of the KMS Key to use when encrypting the volume. | `string` | `"alias/aws/ebs"` |
| <a name="input_launch_template"></a> [launch\_template](#input\_launch\_template) | Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template | `map(string)` | `null` |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Customize the metadata options of the instance | `map(string)` | `{}` |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` |
| <a name="input_network_interface"></a> [network\_interface](#input\_network\_interface) | Customize network interfaces to be attached at instance boot time | `list(map(string))` | `[]` |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system type `lnx` or `win` | `string` | `"lnx"` |
| <a name="input_partition_type"></a> [partition\_type](#input\_partition\_type) | Create and format secondary partition. Can be flat or lvm | `string` | `"flat"` |
| <a name="input_placement_group"></a> [placement\_group](#input\_placement\_group) | The Placement Group to start the instance in | `string` | `""` |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `string` | `null` |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Customize details about the root block device of the instance. | `list(map(string))` | <pre>[<br/>  {<br/>    "volume_type": "gp3"<br/>  }<br/>]</pre> |
| <a name="input_secondary_private_ips"></a> [secondary\_private\_ips](#input\_secondary\_private\_ips) | A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a `network_interface block` | `list(string)` | `null` |
| <a name="input_server_prefix"></a> [server\_prefix](#input\_server\_prefix) | Server name prefix | `string` | `""` |
| <a name="input_server_suffix"></a> [server\_suffix](#input\_server\_suffix) | Server DNS suffix | `string` | `""` |
| <a name="input_source_dest_check"></a> [source\_dest\_check](#input\_source\_dest\_check) | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. | `bool` | `true` |
| <a name="input_spot_block_duration_minutes"></a> [spot\_block\_duration\_minutes](#input\_spot\_block\_duration\_minutes) | The required duration for the Spot instances, in minutes. This value must be a multiple of 60 (60, 120, 180, 240, 300, or 360) | `number` | `null` |
| <a name="input_spot_instance_interruption_behavior"></a> [spot\_instance\_interruption\_behavior](#input\_spot\_instance\_interruption\_behavior) | Indicates Spot instance behavior when it is interrupted. Valid values are `terminate`, `stop`, or `hibernate` | `string` | `null` |
| <a name="input_spot_launch_group"></a> [spot\_launch\_group](#input\_spot\_launch\_group) | A launch group is a group of spot instances that launch together and terminate together. If left empty instances are launched and terminated individually | `string` | `null` |
| <a name="input_spot_price"></a> [spot\_price](#input\_spot\_price) | The maximum price to request on the spot market. Defaults to on-demand price | `string` | `null` |
| <a name="input_spot_type"></a> [spot\_type](#input\_spot\_type) | If set to one-time, after the instance is terminated, the spot request will be closed. Default `persistent` | `string` | `null` |
| <a name="input_spot_valid_from"></a> [spot\_valid\_from](#input\_spot\_valid\_from) | The start date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ) | `string` | `null` |
| <a name="input_spot_valid_until"></a> [spot\_valid\_until](#input\_spot\_valid\_until) | The end date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ) | `string` | `null` |
| <a name="input_spot_wait_for_fulfillment"></a> [spot\_wait\_for\_fulfillment](#input\_spot\_wait\_for\_fulfillment) | If set, Terraform will wait for the Spot Request to be fulfilled, and will throw an error if the timeout of 10m is reached | `bool` | `null` |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The VPC Subnet ID to launch in | `list` | `[]` |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host. | `string` | `"default"` |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Define maximum timeout for creating, updating, and deleting EC2 instance resources | `map(string)` | `{}` |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | When used in combination with user\_data or user\_data\_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set. | `bool` | `false` |
| <a name="input_volume_tags"></a> [volume\_tags](#input\_volume\_tags) | A mapping of tags to assign to the devices created by the instance at launch time | `map(string)` | `{}` |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | A list of security group IDs to associate with | `list(string)` | n/a |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | List of ARNs of instances |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | List of availability zones of instances |
| <a name="output_capacity_reservation_specification"></a> [capacity\_reservation\_specification](#output\_capacity\_reservation\_specification) | Capacity reservation specification of the instance |
| <a name="output_credit_specification"></a> [credit\_specification](#output\_credit\_specification) | List of credit specification of instances |
| <a name="output_id"></a> [id](#output\_id) | List of IDs of instances |
| <a name="output_instance_hostnames"></a> [instance\_hostnames](#output\_instance\_hostnames) | List of IDs of instances |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped` |
| <a name="output_ipv6_addresses"></a> [ipv6\_addresses](#output\_ipv6\_addresses) | The IPv6 address assigned to the instance, if applicable. |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | List of key names of instances |
| <a name="output_outpost_arn"></a> [outpost\_arn](#output\_outpost\_arn) | The ARN of the Outpost the instance is assigned to |
| <a name="output_password_data"></a> [password\_data](#output\_password\_data) | Base-64 encoded encrypted password data for the instance. Useful for getting the administrator password for instances running Microsoft Windows. This attribute is only exported if `get_password_data` is true |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | List of IDs of the primary network interface of instances |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | List of private IP addresses assigned to the instances |
| <a name="output_public_dns"></a> [public\_dns](#output\_public\_dns) | List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | List of public IP addresses assigned to the instances, if applicable |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | List of associated security groups of instances |
| <a name="output_spot_bid_status"></a> [spot\_bid\_status](#output\_spot\_bid\_status) | The current bid status of the Spot Instance Request |
| <a name="output_spot_instance_id"></a> [spot\_instance\_id](#output\_spot\_instance\_id) | The Instance ID (if any) that is currently fulfilling the Spot Instance request |
| <a name="output_spot_request_state"></a> [spot\_request\_state](#output\_spot\_request\_state) | The current request state of the Spot Instance Request |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | List of IDs of VPC subnets of instances |
| <a name="output_tags"></a> [tags](#output\_tags) | List of tags of instances |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block |
| <a name="output_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#output\_vpc\_security\_group\_ids) | List of associated security groups of instances, if running in non-default VPC |
<!-- END_TF_DOCS -->
