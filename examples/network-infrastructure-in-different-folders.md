## Network infrastructure in different folders:

```tf
module "vpc" {
  source = "modules/yc-vpc"

  networks = {
    "dev" = {
      user_net = false
      subnets = {
        "dev-public-1" = {
          zone = "ru-central1-a"
          v4_cidr_blocks = [
            "10.10.10.0/24",
            "10.10.11.0/24"
          ]
        }
        "dev-private-1" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "10.10.12.0/24",
            "10.10.13.0/24"
          ]
        }
        "dev-private-2" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "10.10.14.0/24",
            "10.10.15.0/24"
          ]
        }
      }
    }
    "prod" = {
      user_net = false
      folder_id = "b1gkf5d2rge8qcmou48c"
      subnets = {
        "prod-public-1" = {
          zone = "ru-central1-a"
          v4_cidr_blocks = [
            "10.10.10.0/24",
            "10.10.11.0/24"
          ]
        }
        "prod-public-2" = {
          zone = "ru-central1-d"
          v4_cidr_blocks = [
            "10.10.12.0/24",
            "10.10.13.0/24"
          ]
        }
        "prod-private-1" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "10.10.14.0/24",
            "10.10.15.0/24"
          ]
        }
      }
    }
  }

  nat_gws = {
    "dev"  = {}
    "prod" = {}
  }

  route_table_private_subnets = {
    "dev" = {
      subnets_names = ["dev-private-1", "dev-private-2"]
    }
    "prod" = {
      subnets_names = ["prod-private-1"]
    }
  }

  sec_groups = {
    "prod" = {
      ingress = [
        {
          description = "http"
          from_port = 80
          to_port = 80
          protocol = "TCP"
          v4_cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "https"
          from_port = 443
          to_port = 443
          protocol = "TCP"
          v4_cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "ssh"
          from_port = 22
          to_port = 22
          protocol = "ANY"
          v4_cidr_blocks = ["192.168.100.0/24"]
        },
        {
          description = "icmp"
          from_port = 0
          to_port = 65535
          protocol = "ICMP"
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
  "gateway_ids" = tomap({
    "enpkq1c4hc8t8g2bn23q" = {
      "network_id" = "enplpq4n5jcjb1ct6ica"
      "subnets_ids" = tolist([
        "e2l65gbdst332l3ot9ri",
      ])
    }
    "enpkq1tirc5aj452kglo" = {
      "network_id" = "enpcp8hn463v98la9bhb"
      "subnets_ids" = tolist([
        "e2lafs9v99b5r8gtjmmj",
        "e2leo8dfupmoe5una1ns",
      ])
    }
  })
  "networks" = tomap({
    "enpcp8hn463v98la9bhb" = tolist([
      {
        "route_table_id" = "enpetdu37mn4tkao83fu"
        "subnet_id" = "e2lafs9v99b5r8gtjmmj"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.10.12.0/24",
          "10.10.13.0/24",
        ])
        "zone" = "ru-central1-b"
      },
      {
        "route_table_id" = "enpetdu37mn4tkao83fu"
        "subnet_id" = "e2leo8dfupmoe5una1ns"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.10.14.0/24",
          "10.10.15.0/24",
        ])
        "zone" = "ru-central1-b"
      },
      {
        "route_table_id" = tostring(null)
        "subnet_id" = "e9bbklt923em0dc4pcqh"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.10.10.0/24",
          "10.10.11.0/24",
        ])
        "zone" = "ru-central1-a"
      },
    ])
    "enplpq4n5jcjb1ct6ica" = tolist([
      {
        "route_table_id" = "enpsvvkf25n1u2tvb6ul"
        "subnet_id" = "e2l65gbdst332l3ot9ri"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.10.14.0/24",
          "10.10.15.0/24",
        ])
        "zone" = "ru-central1-b"
      },
      {
        "route_table_id" = tostring(null)
        "subnet_id" = "e9bvvpocbcrnquoh7lrg"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.10.10.0/24",
          "10.10.11.0/24",
        ])
        "zone" = "ru-central1-a"
      },
      {
        "route_table_id" = tostring(null)
        "subnet_id" = "fl8hanejmn73sj2e7ugg"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.10.12.0/24",
          "10.10.13.0/24",
        ])
        "zone" = "ru-central1-d"
      },
    ])
  })
  "sec_group_ids" = tomap({
    "enpd8dkptdth0p9i8n78" = {
      "network_id" = "enplpq4n5jcjb1ct6ica"
    }
  })
}
```