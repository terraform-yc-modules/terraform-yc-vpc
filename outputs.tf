output "networks_with_subnets" {
  description = "Networks with subnets"
  value = [
    for net_key, net in var.networks : {
        network_id = net.user_network == false ? yandex_vpc_network.network[net_key].id : net_key
        network_name = net.user_network == false ? yandex_vpc_network.network[net_key].name : null
        subnets = [
          for sub_key, sub in net.subnets : {
            subnet_id = yandex_vpc_subnet.network-subnets["${net_key}.${sub_key}"].id
            subnet_name = yandex_vpc_subnet.network-subnets["${net_key}.${sub_key}"].name
            v4_cidr_blocks = yandex_vpc_subnet.network-subnets["${net_key}.${sub_key}"].v4_cidr_blocks
            zone = yandex_vpc_subnet.network-subnets["${net_key}.${sub_key}"].zone
            public = sub.public
          }
        ]
      }
  ]
}