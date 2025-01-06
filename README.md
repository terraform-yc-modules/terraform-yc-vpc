# Terraform Yandex VPC Module

This Terraform module is designed for creating and managing Virtual Private Clouds (VPCs) in Yandex Cloud. It provides flexible options for creating networks, subnets, NAT gateways, route tables, and security groups.

## Description

The module allows you to create VPCs with various configurations, including:

•   **Networks:** Creating new networks or using existing ones.  
•   **Subnets:** Creating subnets in different availability zones with customizable CIDR blocks.  
•   **NAT Gateways:** Creating NAT gateways to provide internet access for resources in private subnets.  
•   **Route Tables:** Configuring route tables for public and private subnets.  
•   **Security Groups:** Creating security groups to manage inbound and outbound traffic.  

The module is intended to simplify and standardize the process of creating VPCs in Yandex Cloud, making it more automated and reliable.  

## Usage  

To use the module, you need to define variable values in your Terraform configuration file. Below are the descriptions of the variables and an example of how to use them.  

### Variables  

#### `folder_id`  

•   **(Optional)** The ID of the Yandex Cloud folder where the resources will be created. If not specified, the `folder_id` from the client configuration will be used.  
•   **Type:** `string`  
•   **Default:** `null`  

#### `networks`  

•   **(Optional)** Configuration of networks and subnets.  
•   **Type:** `map(object(...))`  
•   **Description:**  
```
    `folder_id`: (Optional) The folder ID to host the network.  
    `user_net`: (Required) If `true`, an existing network will be used; otherwise, a new one will be created.  
    `subnets`: (Optional) Map of subnets.  
        `zone`: (Required) The availability zone for the subnet.  
        `v4_cidr_blocks`: (Required) List of IPv4 CIDR blocks.  
        `folder_id`: (Optional) The folder ID to host the subnet.  
        `labels`: (Optional) Map of labels.
```

#### `nat_gws`  

•   **(Optional)** Configuration of NAT gateways.  
•   **Type:** `map(object(...))`  
•   **Description:**  
    •   `name`: (Optional) The name of the NAT gateway, defaults to "nat-gw".  

#### `route_table_public_subnets`  

•   **(Optional)** Configuration of route tables for public subnets.  
•   **Type:** `map(object(...))`  
•   **Description:**  
```
    `name`: (Optional) The name of the route table, defaults to "route_table_public".  
    `subnets_names`: (Required) List of subnet names.  
        `static_routes`: (Optional) List of static routes.  
            `destination_prefix`: (Required) The destination prefix.  
            `next_hop_address`: (Required) The IP address of the next hop.
```

#### `route_table_private_subnets`  

•   **(Optional)** Configuration of route tables for private subnets.  
•   **Type:** `map(object(...))`  
•   **Description:**  
```
    `name`: (Optional) The name of the route table, defaults to "route_table_private".  
    `subnets_names`: (Required) List of subnet names.  
    `static_routes`: (Optional) List of static routes.  
        `destination_prefix`: (Required) The destination prefix.  
        `next_hop_address`: (Required) The IP address of the next hop.
```

#### `sec_groups`  

•   **(Optional)** Configuration of security groups.  
•   **Type:** `map(object(...))`  
•   **Description:**  
```
`name`: (Optional) The name of the security group, defaults to "sec-group".  
    `ingress`: (Optional) List of rules for inbound traffic.  
        `description`: (Optional) Description of the rule.  
        `from_port`: (Optional) The starting port.  
        `to_port`: (Optional) The ending port.  
        `v4_cidr_blocks`: (Optional) List of IPv4 CIDR blocks.  
        `protocol`: (Required) Protocol (e.g., tcp, udp, icmp).  
    `egress`: (Optional) List of rules for outbound traffic. (Similar to `ingress`).
```

### Outputs  

#### `networks`  

•   A map of networks and subnets with their IDs, zones, CIDR blocks, and route table IDs.  

#### `gateway_ids`  
 
•   A map of NAT gateway IDs and their associated networks and subnets.  

#### `sec_group_ids`  

•   A map of security group IDs and their associated networks.  

## Requirements  

•   The code is written using Terraform v1.11.0-alpha20241218 on linux_amd64  
•   Yandex Cloud Provider for Terraform  
