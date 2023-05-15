labels              = { tag = " demo" }
network_description = "terraform-created"
network_name        = "net-module"
# domain_name         = "test.com"
# domain_name_servers = ["8.8.8.8", "2.2.2.2"]
# vpc_id = "enp5v4es0f4vgdboXXXX"
create_vpc = true
public_subnets = [
  {
    "v4_cidr_blocks" : ["10.121.0.0/16", "10.122.0.0/16"],
    "zone" : "ru-central1-a"
  },
  {
    "v4_cidr_blocks" : ["10.131.0.0/16"],
    "zone" : "ru-central1-b"
  },
  {
    "v4_cidr_blocks" : ["10.141.0.0/16"],
    "zone" : "ru-central1-c"
  },
]
private_subnets = [
  {
    "v4_cidr_blocks" : ["10.221.0.0/16"],
    "zone" : "ru-central1-a"
  },
  {
    "v4_cidr_blocks" : ["10.231.0.0/16"],
    "zone" : "ru-central1-b"
  },
  {
    "v4_cidr_blocks" : ["10.241.0.0/16"],
    "zone" : "ru-central1-c"
  },
]
routes_public_subnets = [
  {
    destination_prefix : "172.16.0.0/16",
    next_hop_address : "10.131.0.10"
  },
]
routes_private_subnets = [
  {
    destination_prefix : "172.16.0.0/16",
    next_hop_address : "10.231.0.10"
  },
]
