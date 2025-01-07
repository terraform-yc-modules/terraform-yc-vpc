output "networks" {
  description = "Networks with subnets info"

  value = var.networks != null ? {
    for net_key, net in var.networks : try(yandex_vpc_network.network[net_key].id, net_key) => net.subnets != null ? [
      for sub_key, sub in net.subnets : {
        subnet_id        = yandex_vpc_subnet.subnets["${net_key}.${sub_key}"].id
        zone             = yandex_vpc_subnet.subnets["${net_key}.${sub_key}"].zone
        v4_cidr_blocks   = yandex_vpc_subnet.subnets["${net_key}.${sub_key}"].v4_cidr_blocks
        route_table_id   = try(contains(var.route_table_public_subnets[net_key].subnets_names, sub_key), false) ? yandex_vpc_route_table.route_pub_table[net_key].id : try(contains(var.route_table_private_subnets[net_key].subnets_names, sub_key), false) ? yandex_vpc_route_table.route_private_table[net_key].id : null
        subnet_is_public = try(contains(var.route_table_public_subnets[net_key].subnets_names, sub_key), false) ? true : false
      }
    ] : []
  } : {}
}

output "gateway_ids" {
  description = "the IDs of the gateways and the network for which it was created, as well as the subnets to which it is linked"

  value = var.nat_gws != null ? {
    for gw_key, gw in var.nat_gws : yandex_vpc_gateway.nat_gw[gw_key].id => {
      network_id = try(contains(keys(var.networks), gw_key), false) ? try(yandex_vpc_network.network[gw_key].id, gw_key) : null
      subnets_ids = var.route_table_private_subnets != null && try(var.route_table_private_subnets[gw_key].subnets_names, null) != null ? flatten([
        for sub in var.route_table_private_subnets[gw_key].subnets_names : [
          try(yandex_vpc_subnet.subnets["${gw_key}.${sub}"].id, null)
        ]
      ]) : []
    }
  } : {}
}

output "sec_group_ids" {
  description = "ids of the security groups and the networks they are created for"

  value = yandex_vpc_security_group.sec_group != null ? {
    for sec_key, sec in yandex_vpc_security_group.sec_group : yandex_vpc_security_group.sec_group[sec_key].id  => {
      network_id = sec.network_id
    }
  } : {}
}