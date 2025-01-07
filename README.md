# Virtual Private Cloud (VPC) Terraform module for Yandex.Cloud

## Features

-   Create and manage networks and subnets in your Yandex.Cloud folder(s).
-   Supports multi-folder VPC configurations by specifying `folder_id` in network and subnet definitions.
-   Allows creating both user-defined networks or use existing ones
-   Create public subnets for VMs with public IPs and private subnets with or without NAT gateways.
-   Configure route tables for both private and public subnets.
-   Configure security groups for networks.
-   Easy integration with other resources through outputs.

### How to Configure Terraform for Yandex.Cloud

-   Install [YC CLI](https://yandex.cloud/ru/docs/cli/quickstart)
-   Set environment variables for Terraform authentication in Yandex.Cloud:

```bash
  export YC_TOKEN=$(yc iam create-token)
  export YC_CLOUD_ID=$(yc config get cloud-id)
  export YC_FOLDER_ID=$(yc config get folder-id)
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_yandex"></a> [yandex](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider) | >= 0.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_yandex"></a> [yandex](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider) | >= 0.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [yandex_vpc_gateway.nat_gw](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_gateway) | resource |
| [yandex_vpc_network.network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_route_table.route_private_table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table) | resource |
| [yandex_vpc_route_table.route_pub_table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table) | resource |
| [yandex_vpc_security_group.sec_group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_security_group) | resource |
| [yandex_vpc_subnet.subnets](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | (Optional) - The folder id in which the resources will be created, <br/>  if not specified, will be taken from `yandex_client_config` | `string` | `null` | no |
| <a name="input_nat_gws"></a> [nat\_gws](#input\_nat\_gws) | (Optional) - Which networks should create a NAT gateway,<br/>  If you want to create a NAT in an existing network, specify its ID as the key for map()<br/><br/>  Placeholders indicate where to put custom values, <br/>  in this case these are the names or ids of the networks that act as keys for map()<br/><br/>  `<network-name|network-id>`: The name or ID of an existing network for which you need to create a NAT gateway<br/>    `name`: Name of the NAT gateway | <pre>map(object({<br/>    name = optional(string, "nat-gw")<br/>  }))</pre> | `null` | no |
| <a name="input_networks"></a> [networks](#input\_networks) | Networks with subnets configuration.<br/><br/>  ---Important information---<br/>  If you want to specify a user's network, <br/>  then specify its ID and not its name as the map() key.<br/>  ---------------------------<br/><br/>  Placeholders explain where you should insert/come up with <br/>  your own values for resources, in this case for network and subnet names.<br/>  Example: `<network-name>`<br/><br/>  `<network-name|exist-network-id>`: The name of the network to be created or the ID of an existing network<br/>    `folder_id`: ID of the folder where the network will be hosted<br/>    `user_net`: If you specify an already created network, that is, its identifier, then you must specify (true), <br/>                as if to say that this is a user network, for the networks that need to be created, use (false)<br/>    `subnets` Block for subnets configuration<br/>      `zone`: The availability zone where the subnet will be located<br/>      `v4_cidr_blocks`: IPv4 CIDR blocks for this subnet<br/>      `dhcp_options` Block for dhck configure<br/>        `domain_name`: Domain name<br/>        `domain_name_servers`: Domain name servers<br/>        `ntp_servers`: Ntp servers<br/>      `labels`: Labels for this subnet. | <pre>map(object({<br/>    folder_id = optional(string)<br/>    user_net  = bool<br/>    subnets = optional(map(object({<br/>      zone           = string<br/>      v4_cidr_blocks = list(string)<br/>      dhcp_options = optional(object({<br/>        domain_name         = optional(string, "internal.")<br/>        domain_name_servers = optional(list(string), [])<br/>        ntp_servers         = optional(list(string), [])<br/>      }), {})<br/>      labels = optional(map(string))<br/>    })), null)<br/>  }))</pre> | `null` | no |
| <a name="input_route_table_private_subnets"></a> [route\_table\_private\_subnets](#input\_route\_table\_private\_subnets) | (Optional) - Routing table for private network subnets.<br/><br/>  Placeholders indicate where to put custom values, <br/>  in this case these are the names or ids of the networks that act as keys for map()<br/><br/>  `<network-name|network-id>`: The name of the network or the ID of the existing <br/>                               network for which subnets you need to create a routing table<br/>    `name`: Name of the route table<br/>    `subnets_names`: A list of subnets to which this routing table will be linked. Only subnets for `<network-name|network-id>`<br/>    `static_routes` Block for configure static routes<br/>      `destination_prefix`: Destination prefix<br/>      `next_hop_address`: Next hop | <pre>map(object({<br/>    name          = optional(string, "route_table_private")<br/>    subnets_names = list(string)<br/>    static_routes = optional(list(object({<br/>      destination_prefix = string<br/>      next_hop_address   = string<br/>    })), [])<br/>  }))</pre> | `null` | no |
| <a name="input_route_table_public_subnets"></a> [route\_table\_public\_subnets](#input\_route\_table\_public\_subnets) | (Optional) - Routing table for public network subnets.<br/><br/>  Placeholders indicate where to put custom values, <br/>  in this case these are the names or ids of the networks that act as keys for map()<br/><br/>  ---Important information---<br/>  If you want to assign only a NAT gateway to private networks, then list only the list of these networks, <br/>  without specifying routes, but note that you also need to create a NAT, that is, specify the network in var.nat\_gws<br/>  ---------------------------<br/><br/>  `<network-name|network-id>`: The name of the network or the ID of the existing <br/>                               network for which subnets you need to create a routing table<br/>    `name`: Name of the route table<br/>    `subnets_names`: A list of subnets to which this routing table will be linked. Only subnets for `<network-name|network-id>`<br/>    `static_routes` Block for configure static routes<br/>      `destination_prefix`: Destination prefix<br/>      `next_hop_address`: Next hop | <pre>map(object({<br/>    name          = optional(string, "route_table_public")<br/>    subnets_names = list(string)<br/>    static_routes = list(object({<br/>      destination_prefix = string<br/>      next_hop_address   = string<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_sec_groups"></a> [sec\_groups](#input\_sec\_groups) | (Optional) - Security groups for network.<br/><br/>  Placeholders indicate where to put custom values, <br/>  in this case these are the names or ids of the networks that act as keys for map()<br/><br/>  `<network-name|network-id>`: The name or ID of the network for which you want to create a security group<br/>    `name`: Name of the security group<br/>    `ingress` The rules configuration block for incoming traffic<br/>      `description`: Description<br/>      `from_port`: The initial port that you want to open<br/>      `to_port`: Which port do you want to open ports to, if you want to open only one port, <br/>                 then specify the same port in from\_port and to\_port<br/>      `v4_cidr_blocks`: IPv4 CIDR blocks for rule<br/>      `protocol` Protocol for rule | <pre>map(object({<br/>    name = optional(string, "sec-group")<br/>    ingress = optional(list(object({<br/>      description    = optional(string)<br/>      from_port      = optional(number, -1)<br/>      to_port        = optional(number, -1)<br/>      v4_cidr_blocks = optional(list(string))<br/>      protocol       = string<br/>    })), [])<br/>    egress = optional(list(object({<br/>      description    = optional(string)<br/>      from_port      = optional(number, -1)<br/>      to_port        = optional(number, -1)<br/>      v4_cidr_blocks = optional(list(string))<br/>      protocol       = string<br/>    })), [])<br/>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_ids"></a> [gateway\_ids](#output\_gateway\_ids) | the IDs of the gateways and the network for which it was created, as well as the subnets to which it is linked |
| <a name="output_networks"></a> [networks](#output\_networks) | Networks with subnets info |
| <a name="output_sec_group_ids"></a> [sec\_group\_ids](#output\_sec\_group\_ids) | ids of the security groups and the networks they are created for |