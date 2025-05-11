# 04 - OpenStack Instance with Load Balancer using Terraform

This example demonstrates how to deploy one or more compute instances in OpenStack and configure an Octavia Load Balancer (LBaaS v2) to distribute HTTP traffic across them.

## Features

*   Creates a specified number of compute instances.
*   Installs a simple Apache web server on each instance using `user-data`.
*   Configures a security group for instances to allow SSH and HTTP traffic.
*   Provisions an OpenStack Load Balancer with:
    *   A Listener (for HTTP traffic).
    *   A Pool of backend members (the instances).
    *   A Health Monitor to check the status of backend members.
*   Optionally assigns a Floating IP to the load balancer's VIP for public access.

## Prerequisites

1.  **Terraform Installed:** Ensure Terraform (version >= 1.0) is installed.
2.  **OpenStack Credentials:** Configure your OpenStack provider credentials (e.g., via `clouds.yaml` or environment variables).
3.  **OpenStack Octavia Service:** The Octavia (LBaaS v2) service must be enabled and available in your OpenStack cloud.
4.  **Required OpenStack Resources:**
    *   An existing SSH key pair.
    *   A valid image name (e.g., "Ubuntu 22.04") that supports `cloud-init` for `user-data`.
    *   A valid flavor name.
    *   An existing network and a subnet within that network. Instances and the LB VIP will be on this subnet.
    *   If assigning a floating IP, a valid floating IP pool name.

## Files in this Example

*   `provider.tf`: Configures the OpenStack provider.
*   `variables.tf`: Defines input variables for the configuration.
*   `main.tf`: Contains the main resources:
    *   Network data sources.
    *   Instance security group and rules.
    *   Compute instances (scalable via `instance_count`).
    *   Load balancer, listener, pool, health monitor, and members.
    *   Optional floating IP for the load balancer.
*   `outputs.tf`: Defines output values like instance IPs, LB VIP, and LB floating IP.
*   `README.md`: This documentation file.
*   `terraform.tfvars.example`: An example variables file.
*   `scripts/user-data.sh`: A shell script run on instance boot to set up Apache.

## How to Use

1.  **Clone/Copy:**
    ```bash
    # If you cloned a repository
    cd 04-instance-with-loadbalancer-openstack
    ```

2.  **Prepare Variables:**
    Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the values for your OpenStack environment:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    nano terraform.tfvars
    ```
    **Crucial variables to set:** `key_pair_name`, `network_name`, `subnet_name`.
    Also review `image_name`, `flavor_name`, and `floating_ip_pool` if using a floating IP.

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Plan the Deployment:**
    ```bash
    terraform plan
    ```
    Review the plan. This will create several resources, including instances and load balancer components.

5.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```
    Type `yes` when prompted. Deployment might take a few minutes as instances boot and the load balancer is provisioned.

6.  **Access the Application:**
    After successful deployment, use the `loadbalancer_access_url` output to access your web application. The load balancer will distribute requests to the backend instances. You should see "Hello World from hostname" messages, with the hostname changing if you refresh (due to round-robin).

7.  **Check Instance Status (Optional):**
    You can use the `instance_ssh_commands` output as a template to SSH into individual instances for troubleshooting, but you'll likely need to assign floating IPs to them directly or use a bastion host if they are on a private network.

8.  **Clean Up:**
    When you no longer need the resources, destroy them:
    ```bash
    terraform destroy
    ```
    Type `yes` when prompted.

## Inputs

| Name                    | Description                                                                 | Type     | Default                    |
| ----------------------- | --------------------------------------------------------------------------- | -------- | -------------------------- |
| `instance_basename`     | Base name for the compute instances.                                        | `string` | `"lb-member-vm"`           |
| `instance_count`        | Number of instances to create behind the load balancer.                     | `number` | `2`                        |
| `image_name`            | Name of the image to use for the instances.                                 | `string` | `"Ubuntu 22.04"`           |
| `flavor_name`           | Name of the flavor to use for the instances.                                | `string` | `"m1.small"`               |
| `key_pair_name`         | Name of the SSH key pair to use for the instances.                          | `string` | (required)                 |
| `network_name`          | Name of the network for instances and LB VIP.                               | `string` | (required)                 |
| `subnet_name`           | Name of the subnet (in `network_name`) for instances and LB VIP.            | `string` | (required)                 |
| `instance_sg_name`      | Name for the security group for the instances.                              | `string` | `"lb-instance-sg"`         |
| `ssh_allowed_cidr`      | CIDR block to allow SSH access from to the instances.                       | `string` | `"0.0.0.0/0"`              |
| `http_allowed_cidr`     | CIDR block to allow HTTP access from to the instances.                      | `string` | `"0.0.0.0/0"`              |
| `lb_name`               | Name for the load balancer.                                                 | `string` | `"my-web-lb"`              |
| `lb_listener_port`      | Port the load balancer listener will listen on.                             | `number` | `80`                       |
| `lb_pool_member_port`   | Port the backend instances are listening on.                                | `number` | `80`                       |
| `assign_lb_floating_ip` | Whether to assign a floating IP to the load balancer VIP.                   | `bool`   | `true`                     |
| `floating_ip_pool`      | Name of the floating IP pool to use if `assign_lb_floating_ip` is true.     | `string` | `"public"`                 |
| `availability_zone`     | Availability zone for the instances.                                        | `string` | `"nova"`                   |

## Outputs

| Name                         | Description                                                                                             |
| ---------------------------- | ------------------------------------------------------------------------------------------------------- |
| `instance_ids`               | List of IDs of the created instances.                                                                   |
| `instance_fixed_ips`         | List of fixed IP addresses of the instances.                                                            |
| `instance_ssh_commands`      | Example SSH commands for direct instance access (network permitting).                                   |
| `loadbalancer_id`            | The ID of the created load balancer.                                                                    |
| `loadbalancer_vip_address`   | The VIP address of the load balancer on the internal network.                                           |
| `loadbalancer_floating_ip`   | The floating IP address assigned to the load balancer, if any.                                          |
| `loadbalancer_access_url`    | URL to access the load balanced application.                                                            |
| `instance_security_group_id` | ID of the security group created for the instances.                                                     |