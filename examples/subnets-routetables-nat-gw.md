## Creating a network with subnets and a routing table for private and public subnets with different networks:

```tf
module "test_vpc" {
  source = "modules/yc-vpc"

  networks = {
    "foo" = {
      user_net = false
      subnets = {
        "private" = {
          zone = "ru-central1-a"
          v4_cidr_blocks = [
            "10.0.0.0/24"
          ]
        }
      }
    } 
    "bar" = {
      user_net = false
      subnets = {
        "public" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "192.168.100.0/24"
          ]
        }
        "public-2" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "192.168.101.0/24"
          ]
        }
      }
    }
  }

  nat_gws = {
    "foo" = {}
  }

  route_table_private_subnets = {
    "foo" = {
      subnets_names = ["private"]
    }
  }

  route_table_public_subnets = {
    "bar" = {
      subnets_names = ["public", "public-2"]
      static_routes = [
        {
          destination_prefix = "44.44.44.44/32"
          next_hop_address = "192.168.101.100"
        }
      ]
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = tomap({
    "enpkq1kjqmmic1a43iie" = {
      "network_id" = "enpu8kd0k2g6m0a633gk"
      "subnets_ids" = tolist([
        "e9b7qm0l5h147k2ud54s",
      ])
    }
  })
  "networks" = tomap({
    "enp5ugvu0kjcgnp0peof" = tolist([
      {
        "route_table_id" = "enp10n97k3i974v8hkph"
        "subnet_id" = "e2ltgdm1ae372d3re86q"
        "subnet_is_public" = true
        "v4_cidr_blocks" = tolist([
          "192.168.100.0/24",
        ])
        "zone" = "ru-central1-b"
      },
      {
        "route_table_id" = "enp10n97k3i974v8hkph"
        "subnet_id" = "e2leqdbicjjv43qjvs65"
        "subnet_is_public" = true
        "v4_cidr_blocks" = tolist([
          "192.168.101.0/24",
        ])
        "zone" = "ru-central1-b"
      },
    ])
    "enpu8kd0k2g6m0a633gk" = tolist([
      {
        "route_table_id" = "enphqip0okrgteo6o4r5"
        "subnet_id" = "e9b7qm0l5h147k2ud54s"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.0.0.0/24",
        ])
        "zone" = "ru-central1-a"
      },
    ])
  })
  "sec_group_ids" = {}
}
```