data "yandex_client_config" "client" {}

locals {
  folder_id = var.folder_id != null ? var.folder_id : data.yandex_client_config.client.folder_id
}

resource "yandex_vpc_network" "network" {

  for_each = var.networks != null ? {
    for net_key, net in var.networks : net_key => {
      folder_id = net.folder_id != null ? net.folder_id : local.folder_id
    } if net.user_net != true
  } : {}

  name      = each.key
  folder_id = each.value.folder_id
}

resource "yandex_vpc_subnet" "subnets" {

  for_each = var.networks != null ? tomap({
    for subnet in flatten([
      for net_key, net in var.networks : [try(net.subnets, null) != null ?
        [for sub_key, sub in net.subnets : {
          network        = net_key
          subnet_name    = sub_key
          zone           = sub.zone
          network_id     = net.user_net ? net_key : yandex_vpc_network.network[net_key].id
          v4_cidr_blocks = sub.v4_cidr_blocks
          folder_id      = lookup(net, "folder_id", local.folder_id)
          labels         = sub.labels
      }] : []]
    ]) : "${subnet.network}.${subnet.subnet_name}" => subnet
  }) : {}

  name           = "${each.value.subnet_name}-${substr(each.value.zone, -1, 0)}"
  zone           = each.value.zone
  v4_cidr_blocks = each.value.v4_cidr_blocks
  network_id     = each.value.network_id
  folder_id      = each.value.folder_id
  route_table_id = try(contains(var.route_table_public_subnets[each.value.network].subnets_names, each.value.subnet_name), false) ? yandex_vpc_route_table.route_pub_table[each.value.network].id : try(contains(var.route_table_private_subnets[each.value.network].subnets_names, each.value.subnet_name), false) ? yandex_vpc_route_table.route_private_table[each.value.network].id : null
  labels         = each.value.labels
}

resource "yandex_vpc_gateway" "nat_gw" {

  for_each = var.nat_gws != null ? var.nat_gws : {}

  folder_id = try(yandex_vpc_network.network[each.key].folder_id, var.networks != null ? lookup(var.networks[each.key], "folder_id", local.folder_id) : local.folder_id)
  name      = each.value.name

  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "route_pub_table" {

  for_each = var.route_table_public_subnets != null ? var.route_table_public_subnets : {}

  name       = each.value.name
  network_id = try(yandex_vpc_network.network[each.key].id, each.key)
  folder_id  = try(yandex_vpc_network.network[each.key].folder_id, lookup(var.networks[each.key], "folder_id", local.folder_id))

  dynamic "static_route" {
    for_each = each.value.static_routes

    content {
      destination_prefix = static_route.value.destination_prefix
      next_hop_address   = static_route.value.next_hop_address
    }
  }
}

resource "yandex_vpc_route_table" "route_private_table" {

  for_each = var.route_table_private_subnets != null ? var.route_table_private_subnets : {}

  name       = each.value.name
  network_id = try(yandex_vpc_network.network[each.key].id, each.key)
  folder_id  = try(yandex_vpc_network.network[each.key].folder_id, lookup(var.networks[each.key], "folder_id", local.folder_id))

  dynamic "static_route" {
    for_each = each.value.static_routes

    content {
      destination_prefix = static_route.value.destination_prefix
      next_hop_address   = static_route.value.next_hop_address
    }
  }

  dynamic "static_route" {
    for_each = var.nat_gws != null && try(yandex_vpc_gateway.nat_gw[each.key].id, null) != null ? yandex_vpc_gateway.nat_gw : {}

    content {
      destination_prefix = "0.0.0.0/0"
      gateway_id         = yandex_vpc_gateway.nat_gw[each.key].id
    }
  }
}

resource "yandex_vpc_security_group" "sec_group" {

  for_each = var.sec_groups != null ? var.sec_groups : {}

  name       = each.value.name
  network_id = try(yandex_vpc_network.network[each.key].id, each.key)
  folder_id  = try(yandex_vpc_network.network[each.key].folder_id, lookup(var.networks[each.key], "folder_id", local.folder_id))

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      description       = ingress.value.description
      from_port         = ingress.value.from_port
      to_port           = ingress.value.to_port
      v4_cidr_blocks    = ingress.value.v4_cidr_blocks
      protocol          = ingress.value.protocol
    }
  }

  dynamic "egress" {
    for_each = each.value.egress

    content {
      description       = egress.value.description
      from_port         = egress.value.from_port
      to_port           = egress.value.to_port
      v4_cidr_blocks    = egress.value.v4_cidr_blocks
      protocol          = egress.value.protocol
    }
  }
}