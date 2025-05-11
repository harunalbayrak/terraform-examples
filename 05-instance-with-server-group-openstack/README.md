# 05 - OpenStack Instances with a Server Group using Terraform

This example demonstrates how to create multiple OpenStack compute instances that are part of a Server Group. Server Groups allow you to define placement policies (like `affinity` or `anti-affinity`) for your instances, which can be crucial for high availability or performance optimization.

## Features

*   Creates an OpenStack Server Group with a user-defined policy (e.g., `anti-affinity`).
*   Provisions a specified number of compute instances and associates them with the server group using `scheduler_hints`.
*   Creates a security group for the instances, allowing SSH access.
*   Optionally assigns a Floating IP to the first instance in the group for easy access.

## What is a Server Group?

Server groups in OpenStack Nova allow you to influence how the scheduler places your virtual machines. Common policies include:

*   **`affinity`**: Tells the scheduler to try to place all instances in the group on the *same* compute host. Useful for applications that benefit from low latency communication between instances.
*   **`anti-affinity`**: Tells the scheduler to try to place each instance in the group on a *different* compute host. This is essential for high availability, as it reduces the impact of a single host failure.
*   **`soft-affinity` / `soft-anti-affinity`**: Similar to the above, but the scheduler will still place the instance if the policy cannot be strictly met, rather than failing the scheduling request.

## Prerequisites

1.  **Terraform Installed:** Ensure Terraform (version >= 1.0) is installed.
2.  **OpenStack Credentials:** Configure your OpenStack provider credentials (e.g., via `clouds.yaml` or environment variables).
3.  **Required OpenStack Resources:**
    *   An existing SSH key pair.
    *   A valid image name (e.g., "Ubuntu 22.04").
    *   A valid flavor name.
    *   An existing network for the instances.
    *   If assigning a floating IP, a valid floating IP pool name.
    *   Your OpenStack cloud must support server groups and the chosen policy.

## Files in this Example

*   `provider.tf`: Configures the OpenStack provider.
*   `variables.tf`: Defines input variables for the configuration (instance details, server group policy, etc.).
*   `main.tf`: Contains the main resources:
    *   Data sources for network, image, and flavor.
    *   `openstack_networking_secgroup_v2` for instance security.
    *   `openstack_compute_servergroup_v2` to define the server group and its policy.
    *   `openstack_compute_instance_v2` resources that use `scheduler_hints` to join the server group.
    *   Optional floating IP resources.
*   `outputs.tf`: Defines output values like server group ID, instance IPs, etc.
*   `README.md`: This documentation file.
*   `terraform.tfvars.example`: An example variables file.

## How to Use

1.  **Clone/Copy:**
    ```bash
    # If you cloned a repository
    cd 05-instance-with-server-group-openstack
    ```

2.  **Prepare Variables:**
    Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the values:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    nano terraform.tfvars
    ```
    **Key variables to set:** `key_pair_name`, `network_name`. You might also want to change `server_group_policy` (e.g., to `affinity` or `soft-anti-affinity`).

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Plan the Deployment:**
    ```bash
    terraform plan
    ```
    Review the plan to see the server group and instances that will be created.

5.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```
    Type `yes` when prompted.

6.  **Verify (Optional):**
    After deployment, you can use OpenStack CLI or Horizon dashboard to:
    *   Check the server group details: `openstack server group show <server_group_name_or_id>`
    *   List instances in the group: `openstack server list --server-group <server_group_id>`
    *   If using `anti-affinity` and you have multiple compute hosts, check which host each instance is on: `openstack server show <instance_id> -f value -c OS-EXT-SRV-ATTR:host`. They should ideally be on different hosts.

7.  **Access Instances:**
    If a floating IP was assigned to the first instance, use the `ssh_command_first_instance` output.

8.  **Clean Up:**
    When you no longer need the resources:
    ```bash
    terraform destroy
    ```
    Type `yes` when prompted.

## Inputs

| Name                                 | Description                                                                                          | Type     | Default                 |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------- | -------- | ----------------------- |
| `instance_basename`                  | Base name for the compute instances. A number will be appended.                                      | `string` | `"sg-member-vm"`        |
| `instance_count`                     | Number of instances to create in the server group.                                                   | `number` | `2`                     |
| `image_name`                         | Name of the image to use for the instances.                                                          | `string` | `"Ubuntu 22.04"`        |
| `flavor_name`                        | Name of the flavor to use for the instances.                                                         | `string` | `"m1.small"`            |
| `key_pair_name`                      | Name of the SSH key pair to use for the instances.                                                   | `string` | (required)              |
| `network_name`                       | Name of the network to attach the instances to.                                                      | `string` | (required)              |
| `security_group_name`                | Name for the security group for the instances.                                                       | `string` | `"sg-instance-sg"`      |
| `ssh_allowed_cidr`                   | CIDR block to allow SSH access from to the instances.                                                | `string` | `"0.0.0.0/0"`           |
| `server_group_name`                  | Name for the server group.                                                                           | `string` | `"my-app-server-group"` |
| `server_group_policy`                | Policy for the server group (e.g., 'anti-affinity', 'affinity').                                     | `string` | `"anti-affinity"`       |
| `availability_zone`                  | Availability zone for the instances.                                                                 | `string` | `"nova"`                |
| `assign_floating_ip_to_first_instance` | Whether to assign a floating IP to the first instance in the group.                                  | `bool`   | `false`                 |
| `floating_ip_pool`                   | Name of the floating IP pool to use if assigning a floating IP.                                      | `string` | `"public"`              |

## Outputs

| Name                           | Description                                                                                          |
| ------------------------------ | ---------------------------------------------------------------------------------------------------- |
| `server_group_id`              | The ID of the created server group.                                                                      |
| `server_group_name`            | The name of the created server group.                                                                    |
| `server_group_policy`          | The policy applied to the server group.                                                                  |
| `instance_ids`                 | List of IDs of the created instances.                                                                    |
| `instance_names`               | List of names of the created instances.                                                                  |
| `instance_fixed_ips`           | List of fixed IP addresses of the instances.                                                             |
| `first_instance_floating_ip`   | The floating IP address assigned to the first instance, if any.                                        |
| `ssh_command_first_instance`   | SSH command to connect to the first instance (if floating IP is assigned and image user is `ubuntu`).  |
| `instance_security_group_id`   | ID of the security group created for the instances.                                                      |