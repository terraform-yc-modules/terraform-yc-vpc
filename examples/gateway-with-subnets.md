## Creating a gateway and network:

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
            "10.10.10.0/24"
          ]
        }
      }

    }
  }
  nat_gws = {
    "foo" = {} # `foo` is the name of the network for which the gateway is being created
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = tomap({
    "enpkq11j1nu71ldmtu2o" = {
      "network_id" = "enp9k8ldqa2lktpmkd0u"
      "subnets_ids" = []
    }
  })
  "networks" = tomap({
    "enp9k8ldqa2lktpmkd0u" = tolist([
      {
        "route_table_id" = null
        "subnet_id" = "e9bbb0sh5o1uvelq1ur6"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.10.10.0/24",
        ])
        "zone" = "ru-central1-a"
      },
    ])
  })
  "sec_group_ids" = {}
}
```

## Creating a gateway without networks and subnets:

```tf
module "test_vpc" {
  source = "modules/yc-vpc"

  nat_gws = {
    "foo" = {
      name = "my-nat-gateway"
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = tomap({
    "enpkq1hfmb9l9p5j44tu" = {
      "network_id" = tostring(null)
      "subnets_ids" = []
    }
  })
  "networks" = {}
  "sec_group_ids" = {}
}
```