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
| [terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart) | >= 1.0.0 |
| [yandex](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider) | >= 0.13 |

## Providers
| Name | Version |
|------|---------|
| [yandex](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#configure-provider) | >= 0.13 |

## Modules

No modules.

## Resources 

| Name | Type |
|------|------|
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |
| [yandex_vpc_network.network](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_network) | resource |
| [yandex_vpc_subnet.subnets](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet) | resource |
| [yandex_vpc_gateway.nat_gw](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_gateway) | resource |
| [yandex_vpc_route_table.route_pub_tables](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table) | resource |
| [yandex_vpc_route_table.route_private_table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table) | resource |
| [yandex_vpc_default_security_group.sec_group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_default_security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `folder_id` | (Optional) - The folder id in which the resources will be created, if not specified, will be taken from `yandex_client_config`. | string | null | no |
| `networks` | Networks with subnets configuration. Describes network settings and subnets within each network. | map(object({ folder_id = optional(string); user_net = bool; subnets = optional(map(object({ zone = string; v4_cidr_blocks = list(string); dhcp_options = optional(object({ domain_name = optional(string, "internal."); domain_name_servers = optional(list(string), []); ntp_servers = optional(list(string), []) }), {}); labels = optional(map(string)) })), null) })) | null | no |
| `nat_gws` | (Optional) - Which networks should create a NAT gateway. Specifies NAT gateway settings for each network. | map(object({ name = optional(string, "nat-gw") })) | null | no |
| `route_table_public_subnets` | (Optional) - Routing table for public network subnets. Describes routing table settings for public subnets. | map(object({ name = optional(string, "route_table_public"); subnets_names = list(string); static_routes = list(object({ destination_prefix = string; next_hop_address = string })) })) | null | no |
| `route_table_private_subnets` | (Optional) - Routing table for private network subnets. Describes routing table settings for private subnets. | map(object({ name = optional(string, "route_table_private"); subnets_names = list(string); static_routes = optional(list(object({ destination_prefix = string; next_hop_address = string })), []) })) | null | no |
| `sec_groups` | (Optional) - Security groups for network. Describes security group settings for each network. | map(object({ name = optional(string, "sec-group"); ingress = optional(list(object({ description = optional(string); from_port = optional(number, -1); to_port = optional(number, -1); v4_cidr_blocks = optional(list(string)); protocol = string })), []); egress = optional(list(object({ description = optional(string); from_port = optional(number, -1); to_port = optional(number, -1); v4_cidr_blocks = optional(list(string)); protocol = string })), []) })) | null | no |

## Outputs 

| Name | Description |
|------|-------------|
| <a name="output_networks"></a> [networks](#output_networks) | Networks with subnets info, including subnet IDs, zones, CIDR blocks, route table IDs, and whether subnets are public. |
| <a name="output_gateway_ids"></a> [gateway\_ids](#output_gateway_ids) | The IDs of the gateways, the network for which they were created, and the subnets to which they are linked. |
| <a name="output_sec_group_ids"></a> [sec\_group\_ids](#output_sec_group_ids) | IDs of the security groups and the networks they are created for. |