# 06 - OpenStack Networking Foundations with Terraform

This example demonstrates how to create a complete private networking environment from scratch in OpenStack using Terraform. This includes a private network, subnet, router, router interfaces, and a security group. An instance is then launched into this custom network.

This is a foundational example for users who want to manage their network topology as code.

## Features

*   Creates a **Private Neutron Network**.
*   Creates a **Subnet** within the private network with specified CIDR and DNS servers.
*   Creates a **Neutron Router**.
*   Connects the router to the private subnet via a **Router Interface**.
*   Connects the router to an **Existing External Network** (specified by the user) to provide outbound internet access.
*   Creates a **Security Group** allowing SSH and ICMP (ping).
*   Launches a **Compute Instance** into the newly created private network.
*   Optionally allocates and associates a **Floating IP** from the external network to the instance for public accessibility.

## Prerequisites

1.  **Terraform Installed:** Ensure Terraform (version >= 1.0) is installed.
2.  **OpenStack Credentials:** Configure your OpenStack provider credentials (e.g., via `clouds.yaml` or environment variables).
3.  **Knowledge of an Existing External Network:** You need to know the name of an existing "external" or "public" network in your OpenStack environment. This network is used by the router for its gateway and is typically where floating IPs are sourced from.
4.  **Required OpenStack Resources (for the instance):**
    *   An existing SSH key pair.
    *   A valid image name (e.g., "Ubuntu 22.04").
    *   A valid flavor name.

## Files in this Example

*   `provider.tf`: Configures the OpenStack provider.
*   `variables.tf`: Defines input variables (network names, CIDRs, instance details, external network name, etc.).
*   `main.tf`: Contains the main resources:
    *   `openstack_networking_network_v2` (private network)
    *   `openstack_networking_subnet_v2` (private subnet)
    *   `openstack_networking_router_v2` (router)
    *   `openstack_networking_router_interface_v2` (connects router to subnet)
    *   `openstack_networking_secgroup_v2` and rules (security)
    *   `openstack_compute_instance_v2` (the VM)
    *   Optional floating IP resources.
*   `outputs.tf`: Defines output values like network IDs, instance IPs, etc.
*   `README.md`: This documentation file.
*   `terraform.tfvars.example`: An example variables file.

## How to Use

1.  **Clone/Copy:**
    ```bash
    # If you cloned a repository
    cd 06-networking-foundations-openstack
    ```

2.  **Prepare Variables:**
    Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the values:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    nano terraform.tfvars
    ```
    **Crucial variables to set:**
    *   `external_network_name`: The name of your existing public/external network.
    *   `key_pair_name`: Your SSH key pair.
    You might also want to adjust `private_network_cidr`, `image_name`, `flavor_name`, etc.

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Plan the Deployment:**
    ```bash
    terraform plan
    ```
    Review the plan to see all the networking components and the instance that will be created.

5.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```
    Type `yes` when prompted. This may take a minute or two as network resources are provisioned.

6.  **Verify Network Connectivity:**
    *   If a floating IP is assigned, use the `ssh_command` output to connect to the instance.
    *   Once inside the instance, try pinging an external address (e.g., `ping 8.8.8.8`) to verify outbound connectivity through the router.

7.  **Clean Up:**
    When you no longer need the resources (this will delete the network, subnet, router, instance, etc.):
    ```bash
    terraform destroy
    ```
    Type `yes` when prompted.

## Inputs

| Name                    | Description                                                                                          | Type          | Default                     |
| ----------------------- | ---------------------------------------------------------------------------------------------------- | ------------- | --------------------------- |
| `prefix`                | A prefix to be used for naming created resources.                                                    | `string`      | `"tf-netfound"`             |
| `private_network_name`  | Name for the new private network.                                                                    | `string`      | `"my-private-network"`      |
| `private_network_cidr`  | CIDR block for the new private network's subnet.                                                     | `string`      | `"10.0.10.0/24"`            |
| `private_subnet_name`   | Name for the new private subnet.                                                                     | `string`      | `"my-private-subnet"`       |
| `dns_nameservers`       | List of DNS nameservers for the subnet.                                                              | `list(string)`| `["8.8.8.8", "8.8.4.4"]`    |
| `router_name`           | Name for the new router.                                                                             | `string`      | `"my-router"`               |
| `external_network_name` | Name of an existing external network to connect the router to for internet access.                   | `string`      | (required)                  |
| `secgroup_name`         | Name for the security group.                                                                         | `string`      | `"allow-ssh-ping"`          |
| `ssh_allowed_cidr`      | CIDR block to allow SSH access from.                                                                 | `string`      | `"0.0.0.0/0"`               |
| `instance_name`         | Name of the compute instance.                                                                        | `string`      | `"test-vm-on-custom-net"`   |
| `image_name`            | Name of the image to use for the instance.                                                           | `string`      | `"Ubuntu 22.04"`            |
| `flavor_name`           | Name of the flavor to use for the instance.                                                          | `string`      | `"m1.small"`                |
| `key_pair_name`         | Name of the SSH key pair to use for the instance.                                                    | `string`      | (required)                  |
| `availability_zone`     | Availability zone for the instance.                                                                  | `string`      | `"nova"`                    |
| `assign_floating_ip`    | Whether to assign a floating IP to the instance.                                                     | `bool`        | `true`                      |

## Outputs

| Name                     | Description                                                                                          |
| ------------------------ | ---------------------------------------------------------------------------------------------------- |
| `private_network_id`     | ID of the created private network.                                                                   |
| `private_network_name`   | Name of the created private network.                                                                 |
| `private_subnet_id`      | ID of the created private subnet.                                                                    |
| `private_subnet_cidr`    | CIDR of the created private subnet.                                                                  |
| `router_id`              | ID of the created router.                                                                            |
| `router_name`            | Name of the created router.                                                                          |
| `security_group_id`      | ID of the created security group.                                                                    |
| `instance_id`            | ID of the created instance.                                                                          |
| `instance_name`          | Name of the created instance.                                                                        |
| `instance_fixed_ip`      | Fixed IP address of the instance in the private network.                                             |
| `instance_floating_ip`   | Floating IP address assigned to the instance, if any.                                                |
| `ssh_command`            | SSH command to connect to the instance (if floating IP is assigned and image user is `ubuntu`).      |