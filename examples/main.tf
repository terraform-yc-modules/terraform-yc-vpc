module "net" {
  source              = "../"
  labels              = { tag = "example" }
  network_description = "terraform-created"
  network_name        = "vpc-module-example"
  create_vpc          = true
  # s3_private_endpoint = {
  #   enable = true
  # }
  public_subnets = [
    {
      "v4_cidr_blocks" : ["10.121.0.0/16"],
      "zone" : "ru-central1-a"
    },
    {
      "v4_cidr_blocks" : ["10.131.0.0/16"],
      "zone" : "ru-central1-b"
    },
    {
      "v4_cidr_blocks" : ["10.141.0.0/16"],
      "zone" : "ru-central1-d"
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
      "zone" : "ru-central1-d"
    },
  ]
  routes_private_subnets = [
    {
      destination_prefix : "172.16.0.0/16",
      next_hop_address : "10.231.0.10"
    },
  ]
}
