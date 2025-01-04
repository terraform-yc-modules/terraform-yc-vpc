variable "prefix_name" {
  description = "(Optional) - Prefix for resource names. If not provided, then: defprfx"
  type        = string
  default     = "defprfx"
}

variable "networks" {
  description = <<EOF
  Variable for creating networks and subnets.

  Placeholders explain where the user should set their values. Namely, the names of networks and subnets.
  Example: <network-name>, this placeholder indicates the name of the network that you should come up with.


  `<network-name|network-id>`: The name of the network or its ID, in case you want to use an existing network rather than create a new one.
    `user_network`: It has the bool type, if you specify the ID of an existing network, you must set `true` else `false`.
    `folder_id`: The ID of the directory where the network will be located, if not specified, will be taken from client config.
    `labels`: Labels for the network.
    `subnets` A block for configuring subnets.
      `<subnet-name>`: The name of the subnet you want to create.
        `public`: It has the bool type. If you want to classify this network as public, specify `true`.
        `folder_id`: The ID of the folder where the subnet will be located, if not specified, will be taken from the network.folder_id, if not specified, will be taken from client config.
        `zone`: The availability zone where the subnet will be located.
        `v4_cidr_blocks`: v4 cidr blocks from the allowed range for this subnet.
        `labels`: Labels for the subnet.


  For example, see default block.
  EOF
  type = map(object({
    user_network = bool
    folder_id    = optional(string)
    labels       = optional(map(string), {})
    subnets = optional(map(object({
      public         = bool
      folder_id      = optional(string)
      zone           = string
      v4_cidr_blocks = list(string)
      labels         = optional(map(string), {})
      dhcp_options = optional(object({
        domain_name         = optional(string, "internal.")
        domain_name_servers = optional(list(string), [])
        ntp_servers         = optional(list(string), [])
      }), {})
    })), {})
  }))
  default = {
    "network" = {
      user_network = false
      subnets = {
        "foo" = {
          zone   = "ru-central1-b"
          public = false
          v4_cidr_blocks = [
            "192.168.100.0/24"
          ]
        }
      }
    }
    "f7k2jfh2q3nfdk2" = {
      user_network = true
      subnets = {
        "bar" = {
          zone = "ru-central1-a"
          public = true
          v4_cidr_blocks = [
            "10.10.10.0/24"
          ]
        }
      }
    }
  }
}

variable "create_nat_gw" {
  description = "NAT gateways for networks, list the network set for which gateways need to be created"
  type        = set(string)
  default     = ["network"]
}

variable "routes_public_subnets" {
  description = <<EOF
  Routing table for public subnets.

  Placeholders explain where the user should set their values. Namely, the names of networks and subnets.
  Example: <network name>, this placeholder indicates the name of the network for which subnets you want to create a routing table.


  `<network-name|network_id>`: The name of the network created through networks or the ID of an existing network
    `user_network`: Is it a user network? If you specify the ID of an existing network, specify true
    `routes` Block for routes configure
      `destination_prefix`: Destination prefix
      `next_hop_address`: Next hop addrss


  For example, see default block
  EOF
  type = map(object({
    user_network = bool
    routes = list(object({
      destination_prefix = string
      next_hop_address   = string
    }))
  }))
  default = null
}

variable "routes_private_subnets" {
  description = <<EOF
  Routing table for private subnets.

  If you want to leave only the nat gateway for a private network without additional routes, then specify only the network and the 
  user_network parameter for which this needs to be done, set routes to [] or do not touch at all.

  Placeholders explain where the user should set their values. Namely, the names of networks and subnets.
  Example: <network name>, this placeholder indicates the name of the network for which subnets you want to create a routing table.


  `<network-name|network_id>`: The name of the network created through networks or the ID of an existing network
    `user_network`: Is it a user network? If you specify the ID of an existing network, specify true
    `routes` Block for routes configure
      `destination_prefix`: Destination prefix
      `next_hop_address`: Next hop addrss


  For example, see default block
  EOF
  type = map(object({
    user_network = bool
    routes = optional(list(object({
      destination_prefix = optional(string)
      next_hop_address   = optional(string)
    })), [])
  }))
  default = {
    "network" = {
      user_network = false
    }
  }
}

variable "sec_groups" {
  description = <<EOF
  Security group for networks.

  Placeholders indicate where the user should set their values. Namely, the names of the networks and subnets.
  Example: <network name>, this placeholder indicates the name of the network for which you want to create a security group

  `<network-name>`: the name of the network for which you want to create a security group
    `name`: Name for security group
    `user_network`: The bool value indicates whether the network belongs to an existing one.
    `labels`: Labels for security group
    `ingress` The rules configuration block for incoming traffic
      `from_port`: The initial port for the range
      `to_port`: The end port for the range
      `v4_cidr_blocks`: v4 cidr blocks for the rule
      `protocol`: Protocol for the rule
      `description`: Description for the rule
      `predefined_target`: Source, used without v4_cidr_blocks, example: elf_security_group or loadbalancer_healthchecks.

  For example, see default blok.
  EOF
  type = map(object({
    name         = optional(string)
    user_network = bool
    labels       = optional(map(string), {})
    ingress = optional(list(object({
      from_port         = optional(number)
      to_port           = optional(number)
      v4_cidr_blocks    = optional(list(string))
      protocol          = string
      description       = optional(string)
      predefined_target = optional(string)
    })), [])
    egress = optional(list(object({
      from_port         = optional(number)
      to_port           = optional(number)
      v4_cidr_blocks    = optional(list(string))
      protocol          = string
      description       = optional(string)
      predefined_target = optional(string)
    })), [])
  }))
  default = {
    "network" = {
      name         = "def-sec-group"
      user_network = false

      ingress = [{
        from_port      = 22
        protocol       = "ANY"
        to_port        = 22
        v4_cidr_blocks = ["0.0.0.0/0"]
        description    = "ssh"
        }, {
        protocol          = "ANY"
        description       = "Communication inside this SG"
        predefined_target = "self_security_group"
        }, {
        protocol       = "ANY"
        description    = "RDP"
        v4_cidr_blocks = ["0.0.0.0/0"]
        from_port      = 3389
        to_port        = 3389
        }, {
        protocol       = "ICMP"
        description    = "ICMP"
        v4_cidr_blocks = ["0.0.0.0/0"]
        }, {
        protocol          = "ANY"
        description       = "NLB check"
        predefined_target = "loadbalancer_healthchecks"
      }]
      egress = [{
        description    = "to internet"
        protocol       = "ANY"
        v4_cidr_blocks = ["0.0.0.0/0"]
      }]
    }
  }
}