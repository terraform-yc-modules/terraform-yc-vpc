output "vpc_id" {
  description = "ID of the created network for internal communications"
  value       = var.create_vpc ? yandex_vpc_network.this[0].id : null
}

output "public_v4_cidr_blocks" {
  description = "List of `v4_cidr_blocks` used in the VPC network"
  value       = flatten([for subnet in yandex_vpc_subnet.public : subnet.v4_cidr_blocks])
}

output "public_subnets" {
  description = "Map of public subnets: `key = first v4_cidr_block`"
  value = { for v in yandex_vpc_subnet.public : v.v4_cidr_blocks[0] => {
    "subnet_id"      = v.id,
    "name"           = v.name,
    "zone"           = v.zone
    "v4_cidr_blocks" = v.v4_cidr_blocks
    "folder_id"      = v.folder_id
    }
  }
}
output "private_v4_cidr_blocks" {
  description = "List of `v4_cidr_blocks` used in the VPC network"
  value       = flatten([for subnet in yandex_vpc_subnet.private : subnet.v4_cidr_blocks])
}

output "private_subnets" {
  description = "Map of private subnets: `key = first v4_cidr_block`"
  value = { for v in yandex_vpc_subnet.private : v.v4_cidr_blocks[0] => {
    "subnet_id"      = v.id,
    "name"           = v.name,
    "zone"           = v.zone
    "v4_cidr_blocks" = v.v4_cidr_blocks
    "folder_id"      = v.folder_id
    }
  }
}

output "s3_private_endpoint_id" {
  description = "S3 Private Endpoint ID"
  value       = var.s3_private_endpoint.enable ? yandex_vpc_private_endpoint.object_storage[0].id : null
}

output "s3_private_endpoint_ip" {
  description = "S3 Private Endpoint IP address"
  value       = var.s3_private_endpoint.enable ? yandex_vpc_private_endpoint.object_storage[0].endpoint_address[0].address : null
}
