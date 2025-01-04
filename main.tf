### Datasource
data "yandex_client_config" "client" {}

### Locals
locals {
  prefix_name = var.prefix_name
  folder_id   = data.yandex_client_config.client.folder_id
}

### Network
resource "yandex_vpc_network" "network" {

  for_each = tomap({
    for network_key, network in var.networks :
    network_key => network if network.user_network == false
  })

  name      = "${local.prefix_name}-${each.key}"
  folder_id = lookup(each.value, "folder_id", local.folder_id)
  labels    = lookup(each.value, "labels", {})
}

### Subnets
resource "yandex_vpc_subnet" "network-subnets" {

  for_each = tomap({ for subnet in flatten([
    for network_key, network in var.networks : [
      for subnet_key, subnet in network.subnets : {
        network_name       = network_key
        subnet_name        = subnet_key
        subnet_type_public = subnet.public
        network_id         = network.user_network == true ? network_key : yandex_vpc_network.network[network_key].id
        zone               = subnet.zone
        v4_cidr_blocks     = subnet.v4_cidr_blocks
        folder_id          = lookup(network, "folder_id", lookup(subnet, "folder_id", local.folder_id))
        dhcp_options       = subnet.dhcp_options
        labels             = lookup(subnet, "labels", {})
      }
    ]
  ]) : "${subnet.network_name}.${subnet.subnet_name}" => subnet })

  name           = "${local.prefix_name}-${each.value.subnet_name}"
  network_id     = each.value.network_id
  zone           = each.value.zone
  v4_cidr_blocks = each.value.v4_cidr_blocks
  route_table_id = each.value.subnet_type_public == true ? try(yandex_vpc_route_table.public[each.value.network_name].id, null) : try(yandex_vpc_route_table.private[each.value.network_name].id, null)

  dhcp_options {
    domain_name         = each.value.dhcp_options.domain_name
    domain_name_servers = each.value.dhcp_options.domain_name_servers
    ntp_servers         = each.value.dhcp_options.ntp_servers
  }

  labels = each.value.labels
}

### Nat gateway
resource "yandex_vpc_gateway" "nat_egress_gw" {

  for_each = var.create_nat_gw != null ? var.create_nat_gw : []

  name      = "${local.prefix_name}-${each.key}"
  folder_id = lookup(var.networks[each.key], "folder_id", local.folder_id)
}


### Route table for public subnets
resource "yandex_vpc_route_table" "public" {

  for_each = var.routes_public_subnets != null ? var.routes_public_subnets : {}

  name       = "${local.prefix_name}-${each.key}-public"
  network_id = each.value.user_network == false ? yandex_vpc_network.network[each.key].id : each.key
  folder_id  = lookup(var.networks[each.key], "folder_id", local.folder_id)

  dynamic "static_route" {
    for_each = each.value

    content {
      destination_prefix = static_route.value["destination_prefix"]
      next_hop_address   = static_route.value["next_hop_address"]
    }

  }

}

### Route table for private subnets
resource "yandex_vpc_route_table" "private" {

  for_each = var.routes_private_subnets != null ? var.routes_private_subnets : {}

  name       = "${local.prefix_name}-${each.key}-private"
  network_id = each.value.user_network == false ? yandex_vpc_network.network[each.key].id : each.key
  folder_id  = lookup(var.networks[each.key], "folder_id", local.folder_id)

  dynamic "static_route" {
    for_each = try(yandex_vpc_gateway.nat_egress_gw[each.key].id, null) != null ? toset([yandex_vpc_gateway.nat_egress_gw[each.key].id]) : []

    content {
      destination_prefix = "0.0.0.0/0"
      gateway_id         = static_route.value
    }
  }

  dynamic "static_route" {
    for_each = each.value.routes

    content {
      destination_prefix = static_route.value["destination_prefix"]
      next_hop_address   = static_route.value["next_hop_address"]
    }

  }

}

### Security group
resource "yandex_vpc_security_group" "sec_group" {

  for_each = var.sec_groups != null ? var.sec_groups : {}

  name       = each.value.name != null ? "${local.prefix_name}-${each.value.name}" : "${local.prefix_name}-network-${each.key}"
  network_id = each.value.user_network == false ? yandex_vpc_network.network[each.key].id : each.key
  folder_id  = lookup(var.networks[each.key], "folder_id", local.folder_id)

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port         = ingress.value.from_port
      to_port           = ingress.value.to_port
      v4_cidr_blocks    = ingress.value.v4_cidr_blocks
      protocol          = ingress.value.protocol
      description       = ingress.value.description
      predefined_target = ingress.value.predefined_target
    }
  }

  dynamic "egress" {
    for_each = each.value.egress

    content {
      from_port         = egress.value.from_port
      to_port           = egress.value.to_port
      v4_cidr_blocks    = egress.value.v4_cidr_blocks
      protocol          = egress.value.protocol
      description       = egress.value.description
      predefined_target = egress.value.predefined_target
    }
  }

  labels = each.value.labels
}
