variable "folder_id" {
  description = <<EOF
  (Optional) - The folder id in which the resources will be created, 
  if not specified, will be taken from `yandex_client_config`
  EOF

  type    = string
  default = null
}

variable "networks" {
  description = <<EOF
  Networks with subnets configuration.

  ---Important information---
  If you want to specify a user's network, 
  then specify its ID and not its name as the map() key.
  ---------------------------

  Placeholders explain where you should insert/come up with 
  your own values for resources, in this case for network and subnet names.
  Example: `<network-name>`

  `<network-name|exist-network-id>`: The name of the network to be created or the ID of an existing network
    `folder_id`: ID of the folder where the network will be hosted
    `user_net`: If you specify an already created network, that is, its identifier, then you must specify (true), 
                as if to say that this is a user network, for the networks that need to be created, use (false)
    `subnets` Block for subnets configuration
      `zone`: The availability zone where the subnet will be located
      `v4_cidr_blocks`: IPv4 CIDR blocks for this subnet
      `dhcp_options` Block for dhck configure
        `domain_name`: Domain name
        `domain_name_servers`: Domain name servers
        `ntp_servers`: Ntp servers
      `labels`: Labels for this subnet. 
  EOF

  type = map(object({
    folder_id = optional(string)
    user_net  = bool
    subnets = optional(map(object({
      zone           = string
      v4_cidr_blocks = list(string)
      dhcp_options = optional(object({
        domain_name         = optional(string, "internal.")
        domain_name_servers = optional(list(string), [])
        ntp_servers         = optional(list(string), [])
      }), {})
      labels = optional(map(string))
    })), null)
  }))
  default = null
}

variable "nat_gws" {
  description = <<EOF
  (Optional) - Which networks should create a NAT gateway,
  If you want to create a NAT in an existing network, specify its ID as the key for map()

  Placeholders indicate where to put custom values, 
  in this case these are the names or ids of the networks that act as keys for map()

  `<network-name|network-id>`: The name or ID of an existing network for which you need to create a NAT gateway
    `name`: Name of the NAT gateway
  EOF

  type = map(object({
    name = optional(string, "nat-gw")
  }))
  default = null
}

variable "route_table_public_subnets" {
  description = <<EOF
  (Optional) - Routing table for public network subnets.

  Placeholders indicate where to put custom values, 
  in this case these are the names or ids of the networks that act as keys for map()

  ---Important information---
  If you want to assign only a NAT gateway to private networks, then list only the list of these networks, 
  without specifying routes, but note that you also need to create a NAT, that is, specify the network in var.nat_gws
  ---------------------------

  `<network-name|network-id>`: The name of the network or the ID of the existing 
                               network for which subnets you need to create a routing table
    `name`: Name of the route table
    `subnets_names`: A list of subnets to which this routing table will be linked. Only subnets for `<network-name|network-id>`
    `static_routes` Block for configure static routes
      `destination_prefix`: Destination prefix
      `next_hop_address`: Next hop
  EOF

  type = map(object({
    name          = optional(string, "route_table_public")
    subnets_names = list(string)
    static_routes = list(object({
      destination_prefix = string
      next_hop_address   = string
    }))
  }))

  default = null
}

variable "route_table_private_subnets" {
  description = <<EOF
  (Optional) - Routing table for private network subnets.

  Placeholders indicate where to put custom values, 
  in this case these are the names or ids of the networks that act as keys for map()

  `<network-name|network-id>`: The name of the network or the ID of the existing 
                               network for which subnets you need to create a routing table
    `name`: Name of the route table
    `subnets_names`: A list of subnets to which this routing table will be linked. Only subnets for `<network-name|network-id>`
    `static_routes` Block for configure static routes
      `destination_prefix`: Destination prefix
      `next_hop_address`: Next hop
  EOF

  type = map(object({
    name          = optional(string, "route_table_private")
    subnets_names = list(string)
    static_routes = optional(list(object({
      destination_prefix = string
      next_hop_address   = string
    })), [])
  }))

  default = null
}

variable "sec_groups" {
  description = <<EOF
  (Optional) - Security groups for network.

  Placeholders indicate where to put custom values, 
  in this case these are the names or ids of the networks that act as keys for map()

  `<network-name|network-id>`: The name or ID of the network for which you want to create a security group
    `name`: Name of the security group
    `ingress` The rules configuration block for incoming traffic
      `description`: Description
      `from_port`: The initial port that you want to open
      `to_port`: Which port do you want to open ports to, if you want to open only one port, 
                 then specify the same port in from_port and to_port
      `v4_cidr_blocks`: IPv4 CIDR blocks for rule
      `protocol` Protocol for rule
  EOF

  type = map(object({
    name = optional(string, "sec-group")
    ingress = optional(list(object({
      description    = optional(string)
      from_port      = optional(number, -1)
      to_port        = optional(number, -1)
      v4_cidr_blocks = optional(list(string))
      protocol       = string
    })), [])
    egress = optional(list(object({
      description    = optional(string)
      from_port      = optional(number, -1)
      to_port        = optional(number, -1)
      v4_cidr_blocks = optional(list(string))
      protocol       = string
    })), [])
  }))

  default = null
}