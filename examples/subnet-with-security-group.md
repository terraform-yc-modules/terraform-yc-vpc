## Security group for network

```tf
module "test_vpc" {
  source = "modules/yc-vpc"

  networks = {
    "foo" = {
      user_net = false
      subnets = {
        "bar" = {
          zone = "ru-central1-a"
          v4_cidr_blocks = [
            "10.0.0.0/24"
          ]
        }
      }
    }
  }
  
  sec_groups = {
    "foo" = {
      ingress = [
        {
          description = "ssh"
          from_port = 22
          to_port = 22
          protocol = "TCP"
          v4_cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          description = "to internet"
          from_port = 0
          to_port = 65535
          protocol = "ANY"
          v4_cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = {}
  "networks" = tomap({
    "enpomtoohvi4in8iuqk0" = tolist([
      {
        "route_table_id" = null
        "subnet_id" = "e9bkdgafik6ul6raevc4"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.0.0.0/24",
        ])
        "zone" = "ru-central1-a"
      },
    ])
  })
  "sec_group_ids" = tomap({
    "enpcbt4ohnisl5b4v58e" = {
      "network_id" = "enpomtoohvi4in8iuqk0"
    }
  })
}
```
