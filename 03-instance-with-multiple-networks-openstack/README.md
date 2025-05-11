# 03 - OpenStack Instance with Multiple Networks using Terraform

This example deploys an OpenStack compute instance and attaches it to multiple specified networks. Optionally, a floating IP can be assigned to its first network interface.

## Prerequisites

1.  **Terraform Installed:** Ensure Terraform (version >= 1.0) is installed.
2.  **OpenStack Credentials:** Configure your OpenStack provider credentials. This is typically done via:
    *   An `clouds.yaml` file.
    *   Environment variables (e.g., `OS_AUTH_URL`, `OS_USERNAME`, etc.).
3.  **Required OpenStack Resources:**
    *   An existing SSH key pair in OpenStack.
    *   Valid image name (e.g., "Ubuntu 22.04").
    *   Valid flavor name (e.g., "m1.small").
    *   At least one, preferably two or more, existing networks in OpenStack for the instance to connect to.
    *   Security group(s) (e.g., "default" or a custom one allowing SSH).
    *   If assigning a floating IP, a valid floating IP pool name.

## Files in this Example

*   `provider.tf`: Configures the OpenStack provider.
*   `variables.tf`: Defines input variables for the configuration (instance name, image, flavor, networks, etc.).
*   `main.tf`: Contains the main resources:
    *   Data sources for image, flavor, and networks.
    *   `openstack_compute_instance_v2` resource to create the instance with multiple network attachments using a dynamic block.
    *   Optional `openstack_networking_floatingip_v2` and `openstack_compute_floatingip_associate_v2` to assign a floating IP.
*   `outputs.tf`: Defines output values like instance ID, IPs, and SSH command.
*   `README.md`: This documentation file.
*   `terraform.tfvars.example`: An example variables file.

## How to Use

1.  **Clone/Copy:**
    ```bash
    # If you cloned a repository
    cd 03-instance-with-multiple-networks-openstack
    ```

2.  **Prepare Variables:**
    Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the values for your OpenStack environment:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    nano terraform.tfvars
    ```
    Ensure `key_pair_name`, `image_name`, `flavor_name`, and `network_names` are correctly set.

3.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

4.  **Plan the Deployment:**
    ```bash
    terraform plan
    ```
    Review the plan to see what resources will be created.

5.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```
    Type `yes` when prompted to confirm.

6.  **Access Instance Information:**
    The outputs will display the instance IPs. If a floating IP is assigned, you can use the provided SSH command.

7.  **Clean Up:**
    When you no longer need the resources, destroy them:
    ```bash
    terraform destroy
    ```
    Type `yes` when prompted.

## Inputs

| Name                  | Description                                                                     | Type         | Default                                     |
| --------------------- | ------------------------------------------------------------------------------- | ------------ | ------------------------------------------- |
| `instance_name`       | Name of the compute instance.                                                   | `string`     | `"multi-network-instance"`                  |
| `image_name`          | Name of the image to use for the instance.                                      | `string`     | `"Ubuntu 22.04"`                            |
| `flavor_name`         | Name of the flavor to use for the instance.                                     | `string`     | `"m1.small"`                                |
| `key_pair_name`       | Name of the SSH key pair to use for the instance.                               | `string`     | (required)                                  |
| `network_names`       | A list of network names to attach the instance to.                              | `list(string)` | `["private-network-1", "private-network-2"]` |
| `security_groups`     | A list of security group names to associate with the instance.                  | `list(string)` | `["default"]`                               |
| `availability_zone`   | Availability zone for the instance.                                             | `string`     | `"nova"`                                    |
| `assign_floating_ip`  | Whether to assign a floating IP to the instance's first network interface.    | `bool`       | `false`                                     |
| `floating_ip_pool`    | Name of the floating IP pool to use if `assign_floating_ip` is true.            | `string`     | `"public"`                                  |

## Outputs

| Name                        | Description                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------- |
| `instance_id`               | The ID of the created instance.                                                                      |
| `instance_name`             | The name of the created instance.                                                                    |
| `instance_networks`         | Network information for the instance, including fixed IPs for each attached network.                 |
| `instance_access_ip_v4`     | The first accessible IPv4 address of the instance.                                                   |
| `instance_floating_ip`      | The floating IP address assigned to the instance, if any.                                            |
| `ssh_command`               | SSH command to connect to the instance (if floating IP is assigned and image user is `ubuntu`).      |