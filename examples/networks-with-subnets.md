## Creating a network with subnets:

```tf
module "vpc" {
  source = "modules/yc-vpc"

  networks = {
    "foo" = {
      user_net = false
      subnets = {
        "foo-bar" = {
          zone = "ru-central1-a"
          v4_cidr_blocks = [
            "10.0.0.0/24"
          ]
        }
      }
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = {}
  "networks" = tomap({
    "enpsv2r9hoh7enck5rg4" = [
      {
        "route_table_id" = null
        "subnet_id" = "e9bgukniu2midte6hsii"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.0.0.0/24",
        ])
        "zone" = "ru-central1-a"
      },
    ]
  })
  "sec_group_ids" = {}
}
```

## Creating subnets for an existing network:

```tf
module "test_vpc" {
  source = "modules/yc-vpc"

  networks = {
    "enpsv2r9hoh7enck5rg4" = {
      user_net = true
      subnets = {
        "foo" = {
          zone = "ru-central1-a"
          v4_cidr_blocks = [
            "10.0.0.0/24"
          ]
        }
        "bar" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "192.168.0.0/24"
          ]
        }
      }
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = {}
  "networks" = tomap({
    "enpsv2r9hoh7enck5rg4" = tolist([
      {
        "route_table_id" = null
        "subnet_id" = "e2l43pv1km238d0vbtkh"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "192.168.0.0/24",
        ])
        "zone" = "ru-central1-b"
      },
      {
        "route_table_id" = null
        "subnet_id" = "e9buocoubre04fg510s6"
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

## Creating networks without subnets:

```tf
module "test_vpc" {
  source = "modules/yc-vpc"

  networks = {
    "foo" = {
      user_net = false
    }
    "bar" = {
      user_net = false
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = {}
  "networks" = tomap({
    "enp13ls1c8iv995h0b2i" = []
    "enphi5p05kenaqmf7kfh" = []
  })
  "sec_group_ids" = {}
}
```

## Creating networks in with subnets in two different folders:

```tf
module "test_vpc" {
  source = "modules/yc-vpc"

  networks = {
    "foo" = {
      user_net = false
      folder_id = "b1goj77baqup6q57l92a"
      subnets = {
        "foo-lol" = {
          zone = "ru-central1-a"
          v4_cidr_blocks = [
            "10.0.0.0/24"
          ]
        }
      }
    }
    "bar" = {
      user_net = false
      folder_id = "b1gkf5d2rge8qcmou48c"
      subnets = {
        "bar-lol" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "10.0.0.0/24"
          ]
        }
      }
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = {}
  "networks" = tomap({
    "enp60d5fp89cd5d15cd5" = tolist([
      {
        "route_table_id" = null
        "subnet_id" = "e9b686ra392cneh10dl1"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.0.0.0/24",
        ])
        "zone" = "ru-central1-a"
      },
    ])
    "enpvla45pp2gdfv41vtq" = tolist([
      {
        "route_table_id" = null
        "subnet_id" = "e2l0ptm2hsb4t1ueisen"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.0.0.0/24",
        ])
        "zone" = "ru-central1-b"
      },
    ])
  })
  "sec_group_ids" = {}
}
```

## Creating subnets for existing networks in two different folders

```tf
module "test_vpc" {
  source = "modules/yc-vpc"

  networks = {
    "enp60d5fp89cd5d15cd5" = {
      user_net = true
      folder_id = "b1goj77baqup6q57l92a"
      subnets = {
        "foo" = {
          zone = "ru-central1-d"
          v4_cidr_blocks = [
            "10.0.0.0/24",
            "192.168.100.0/24"
          ]
        }
      }
    }
    "enpvla45pp2gdfv41vtq" = {
      user_net = true
      folder_id = "b1gkf5d2rge8qcmou48c"
      subnets = {
        "bar" = {
          zone = "ru-central1-b"
          v4_cidr_blocks = [
            "172.16.0.0/16"
          ]
        }
      }
    }
  }
}
```

Outputs:

```
this = {
  "gateway_ids" = {}
  "networks" = tomap({
    "enp60d5fp89cd5d15cd5" = tolist([
      {
        "route_table_id" = null
        "subnet_id" = "fl819cgk2ji1qgce0udc"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "10.0.0.0/24",
          "192.168.100.0/24",
        ])
        "zone" = "ru-central1-d"
      },
    ])
    "enpvla45pp2gdfv41vtq" = tolist([
      {
        "route_table_id" = null
        "subnet_id" = "e2ldudk0jc2pcu7hp1fs"
        "subnet_is_public" = false
        "v4_cidr_blocks" = tolist([
          "172.16.0.0/16",
        ])
        "zone" = "ru-central1-b"
      },
    ])
  })
  "sec_group_ids" = {}
}
```
