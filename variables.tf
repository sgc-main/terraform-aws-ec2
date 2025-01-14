# VM Information
variable os_type {
  description = "Operating system type `lnx` or `win`"
  type        = string
  default     = "lnx"
}

variable server_prefix {
  description = "Server name prefix"
  default     = ""
}

variable server_suffix {
  description = "Server DNS suffix"
  default     = ""
}

variable instance_count {
  description = "Number of instances to launch"
  default     = 1
}

variable instance_static_hostname {
  description = "Static hostname of the instance. To be used for single deployments or with module for_each on a list of names"
  type        = string
  default     = null
}

variable ami {
  description = "ID of AMI to use for the instance"
  type        = string

}

variable placement_group {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable tenancy {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable ebs_optimized {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable enclave_options_enabled {
  description = "Whether Nitro Enclaves will be enabled on the instance. Defaults to `false`"
  type        = bool
  default     = null
}

variable disable_api_termination {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable instance_initiated_shutdown_behavior {
  description = "Shutdown behavior for the instance" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  default     = ""
}

variable instance_type {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable key_name {
  description = "The key name to use for the instance"
  default     = ""
}

variable launch_template {
  description = "Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template"
  type        = map(string)
  default     = null
}

variable metadata_options {
  description = "Customize the metadata options of the instance"
  type        = map(string)
  default     = {}
}

variable monitoring {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable network_interface {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(map(string))
  default     = []
}

variable vpc_security_group_ids {
  description = "A list of security group IDs to associate with"
  type        = list(string)
}

variable timeouts {
  description = "Define maximum timeout for creating, updating, and deleting EC2 instance resources"
  type        = map(string)
  default     = {}
}

variable subnet_ids {
  description = "The VPC Subnet ID to launch in"
  default     = []
}

variable associate_public_ip_address {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}

variable private_ip {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable secondary_private_ips {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a `network_interface block`"
  type        = list(string)
  default     = null
}

variable source_dest_check {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}

variable user_data_replace_on_change {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set."
  type        = bool
  default     = false
}

variable host_id {
  description = "ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host"
  type        = string
  default     = null
}

variable iam_instance_profile {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet"
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type        = list(string)
  default     = null
}

variable tags {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable volume_tags {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable enable_volume_tags {
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  type        = bool
  default     = true
}

variable kms_key_alias {
  description = "ARN of the KMS Key to use when encrypting the volume."
  default     = "alias/aws/ebs"
}

variable root_block_device {
  description = "Customize details about the root block device of the instance."
  type        = list(map(string))
  default     = [
    {
      volume_type = "gp3"
    }
  ]
}

variable ebs_block_device {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable ephemeral_block_device {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type        = list(map(string))
  default     = []
}

variable get_password_data {
  description = "If true, wait for password data to become available and retrieve it."
  type        = bool
  default     = null
}

variable hibernation {
  description = "If true, the launched EC2 instance will support hibernation"
  type        = bool
  default     = null
}

variable capacity_reservation_specification {
  description = "Describes an instance's Capacity Reservation targeting option"
  type        = any
  default     = null
}

variable cpu_credits {
  description = "The credit option for CPU usage (unlimited or standard)"
  default     = "standard"
}

variable partition_type {
  description = "Create and format secondary partition. Can be flat or lvm"
  default     = "flat"
}

variable "dns_servers" {
  description = "Coma separated string of DNS server IP addresses"
  default     = ""
}

variable extended_userdata {
  description = "User-Data additional script"
  default = ""
}

variable extended_userdata_list {
  description = "Userdata: Separate scripts to be executed on each VM in suite. Use-case, service cluster creation"
  default     = []
}

variable count_format {
  description = "Instance hostname iterative number format"
  default     = "%02d"
}

variable "enable_partitioning" {
  description = "Enable Partitioning"
  default     = "true"
}

variable "enable_updates" {
  description = "Enable OS Updates"
  default     = "false"
}

# Spot instance request
variable create_spot_instance {
  description = "Depicts if the instance is a spot instance"
  type        = bool
  default     = false
}

variable spot_price {
  description = "The maximum price to request on the spot market. Defaults to on-demand price"
  type        = string
  default     = null
}

variable spot_wait_for_fulfillment {
  description = "If set, Terraform will wait for the Spot Request to be fulfilled, and will throw an error if the timeout of 10m is reached"
  type        = bool
  default     = null
}

variable spot_type {
  description = "If set to one-time, after the instance is terminated, the spot request will be closed. Default `persistent`"
  type        = string
  default     = null
}

variable spot_launch_group {
  description = "A launch group is a group of spot instances that launch together and terminate together. If left empty instances are launched and terminated individually"
  type        = string
  default     = null
}

variable spot_block_duration_minutes {
  description = "The required duration for the Spot instances, in minutes. This value must be a multiple of 60 (60, 120, 180, 240, 300, or 360)"
  type        = number
  default     = null
}

variable spot_instance_interruption_behavior {
  description = "Indicates Spot instance behavior when it is interrupted. Valid values are `terminate`, `stop`, or `hibernate`"
  type        = string
  default     = null
}

variable spot_valid_until {
  description = "The end date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = null
}

variable spot_valid_from {
  description = "The start date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ)"
  type        = string
  default     = null
}
