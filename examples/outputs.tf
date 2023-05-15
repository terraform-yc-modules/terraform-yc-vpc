output "public_subnets" {
  description = "Public subnets"
  value       = module.net.public_subnets
}
output "private_v4_cidr_blocks" {
  description = "private cidr_blocks"
  value       = module.net.private_v4_cidr_blocks
}
