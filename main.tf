### Datasource
data "yandex_client_config" "client" {}

### Locals
locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
  vpc_id    = var.create_vpc ? yandex_vpc_network.this[0].id : var.vpc_id
}

### Network
resource "yandex_vpc_network" "this" {
  count       = var.create_vpc ? 1 : 0
  description = var.network_description
  name        = var.network_name
  labels      = var.labels
  folder_id   = local.folder_id
}

resource "yandex_vpc_subnet" "public" {
  for_each       = try({ for v in var.public_subnets : v.v4_cidr_blocks[0] => v }, {})
  name           = lookup(each.value, "name", "public-${var.network_name}-${each.value.zone}-${each.value.v4_cidr_blocks[0]}")
  description    = lookup(each.value, "description", "${var.network_name} subnet for zone ${each.value.zone}")
  v4_cidr_blocks = each.value.v4_cidr_blocks
  zone           = each.value.zone
  network_id     = local.vpc_id
  folder_id      = lookup(each.value, "folder_id", local.folder_id)
  route_table_id = yandex_vpc_route_table.public[0].id
  dhcp_options {
    domain_name         = var.domain_name
    domain_name_servers = var.domain_name_servers
    ntp_servers         = var.ntp_servers
  }

  labels = var.labels
}

resource "yandex_vpc_subnet" "private" {
  for_each       = try({ for v in var.private_subnets : v.v4_cidr_blocks[0] => v }, {})
  name           = lookup(each.value, "name", "private-${var.network_name}-${each.value.zone}-${each.value.v4_cidr_blocks[0]}")
  description    = lookup(each.value, "description", "${var.network_name} subnet for zone ${each.value.zone}")
  v4_cidr_blocks = each.value.v4_cidr_blocks
  zone           = each.value.zone
  network_id     = local.vpc_id
  folder_id      = lookup(each.value, "folder_id", local.folder_id)
  route_table_id = yandex_vpc_route_table.private[0].id
  dhcp_options {
    domain_name         = var.domain_name
    domain_name_servers = var.domain_name_servers
    ntp_servers         = var.ntp_servers
  }

  labels = var.labels
}

## Routes
resource "yandex_vpc_gateway" "egress_gateway" {
  count     = var.create_nat_gw && var.private_subnets != null ? 1 : 0
  name      = "${var.network_name}-egress-gateway"
  folder_id = local.folder_id
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "public" {
  count      = var.public_subnets == null ? 0 : 1
  name       = "${var.network_name}-public"
  network_id = local.vpc_id
  folder_id  = local.folder_id

  dynamic "static_route" {
    for_each = var.routes_public_subnets == null ? [] : var.routes_public_subnets
    content {
      destination_prefix = static_route.value["destination_prefix"]
      next_hop_address   = static_route.value["next_hop_address"]
    }
  }

}
resource "yandex_vpc_route_table" "private" {
  count      = var.private_subnets == null ? 0 : 1
  name       = "${var.network_name}-private"
  network_id = local.vpc_id
  folder_id  = local.folder_id

  dynamic "static_route" {
    for_each = var.routes_private_subnets == null ? [] : var.routes_private_subnets
    content {
      destination_prefix = static_route.value["destination_prefix"]
      next_hop_address   = static_route.value["next_hop_address"]
    }
  }
  dynamic "static_route" {
    for_each = var.create_nat_gw ? yandex_vpc_gateway.egress_gateway : []
    content {
      destination_prefix = "0.0.0.0/0"
      gateway_id         = yandex_vpc_gateway.egress_gateway[0].id
    }
  }

}

##Private connections
resource "yandex_vpc_private_endpoint" "object_storage" {
  count       = var.s3_private_endpoint.enable == true ? 1 : 0
  name        = "${var.network_name}-s3-pe"
  description = "S3 private endpoint in ${var.network_name}"

  labels = var.labels

  network_id = local.vpc_id

  object_storage {}

  dns_options {
    private_dns_records_enabled = var.s3_private_endpoint.private_dns_records_enabled
  }

  endpoint_address {
    subnet_id = var.s3_private_endpoint.subnet_v4_cidr_block == null ? yandex_vpc_subnet.private[var.private_subnets[0].v4_cidr_blocks[0]].id : yandex_vpc_subnet.private[var.s3_private_endpoint.subnet_v4_cidr_block].id
    address   = var.s3_private_endpoint.address
  }
}

## Default Security Group
resource "yandex_vpc_default_security_group" "default_sg" {
  count       = var.create_vpc && var.create_sg ? 1 : 0
  description = "Default security group"
  network_id  = local.vpc_id
  folder_id   = local.folder_id
  labels      = var.labels

  ingress {
    protocol          = "ANY"
    description       = "Communication inside this SG"
    predefined_target = "self_security_group"

  }
  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22

  }
  ingress {
    protocol       = "TCP"
    description    = "RDP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 3389

  }
  ingress {
    protocol       = "ICMP"
    description    = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    protocol          = "TCP"
    description       = "NLB health check"
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    description    = "To the Internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
