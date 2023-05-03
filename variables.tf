variable "create_vpc" {
  type        = bool
  default     = true
  description = "Shows whether a VCP object should be created. If false, an existing `vpc_id` is required."
}

variable "create_sg" {
  type        = bool
  default     = true
  description = "Shows whether а security group for VCP object should be created"
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "Existing `network_id` (`vpc-id`) where resources will be created"
}

variable "network_name" {
  description = "Prefix to be used with all the resources as an identifier"
  type        = string
}

variable "network_description" {
  description = "Optional description of this resource. Provide this property when you create the resource."
  type        = string
  default     = "terraform-created"
}

variable "folder_id" {
  type        = string
  default     = null
  description = "Folder ID where the resources will be created"
}

variable "public_subnets" {
  description = "Describe your public subnet preferences"
  type = list(object({
    zone           = string
    v4_cidr_blocks = list(string)
  }))
  default = null
}

variable "private_subnets" {
  description = "Describe your private subnet preferences"
  type = list(object({
    zone           = string
    v4_cidr_blocks = list(string)
  }))
  default = null
}

variable "create_nat_gw" {
  description = "Create a NAT gateway for internet access from private subnets"
  type        = bool
  default     = true
}

variable "routes_public_subnets" {
  description = "Describe your route preferences for public subnets"
  type = list(object({
    destination_prefix = string
    next_hop_address   = string
  }))
  default = null
}
variable "routes_private_subnets" {
  description = "Describe your route preferences for public subnets"
  type = list(object({
    destination_prefix = string
    next_hop_address   = string
  }))
  default = null
}
variable "domain_name" {
  type        = string
  default     = null
  description = "Domain name to be added to DHCP options"
}

variable "domain_name_servers" {
  type        = list(string)
  default     = []
  description = "Domain name servers to be added to DHCP options"
}
variable "ntp_servers" {
  type        = list(string)
  default     = []
  description = "NTP Servers for subnets"
}
variable "labels" {
  description = "Set of key/value label pairs to assign."
  type        = map(string)
  default     = null
}
