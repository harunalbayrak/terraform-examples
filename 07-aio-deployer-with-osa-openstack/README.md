# 07 - OpenStack-Ansible (OSA) All-In-One (AIO) Deployer with Terraform

This Terraform configuration provisions a virtual machine on an existing OpenStack cloud and then uses `cloud-init` (`user_data`) to trigger an OpenStack-Ansible (OSA) All-In-One (AIO) installation within that VM.

## Features

*   Deploys a VM on an existing OpenStack environment.
*   Dynamically creates a security group with configurable ports (defaults for SSH, HTTP/S, and common OpenStack API endpoints).
*   Automatically allocates and associates a floating IP to the VM.
*   Uses `user_data` (cloud-init) to execute the OSA installation script on the first boot of the VM. Terraform does *not* wait for OSA installation to complete.
*   Configurable OSA branch/tag.
*   Terraform variables to toggle the enablement of core OpenStack services (Heat, Cinder, Swift, Horizon, etc.) within the OSA deployment.
*   Optional password-based SSH access to the VM (use with caution; key-based is strongly recommended).
*   Customizable tags for the provisioned VM.
*   Configurable OSA environment layout, scenario, and infrastructure provider.

## Prerequisites

1.  **Terraform CLI**: Version >= 1.0 installed.
2.  **OpenStack RC File**: Source your OpenStack RC file (`source your-openstack-rc-file.sh`) to set up the necessary environment variables for Terraform to authenticate with your OpenStack cloud.
    These typically include: `OS_AUTH_URL`, `OS_USERNAME`, `OS_PASSWORD`, `OS_PROJECT_NAME` (or `OS_PROJECT_ID`), `OS_USER_DOMAIN_NAME`, `OS_PROJECT_DOMAIN_NAME`, `OS_REGION_NAME`.
3.  **Existing SSH Key Pair**: An SSH key pair must be present in your OpenStack project. You will provide its name via the `aio_key_pair_name` variable.
4.  **Suitable Base Image**: A compatible Linux image (e.g., Ubuntu 22.04 LTS, CentOS Stream 9) that supports `cloud-init`. Provide its name via `aio_image_name`.
5.  **Sufficient Flavor**: The OSA AIO installation is resource-intensive. Select a flavor (`aio_flavor_name`) with adequate vCPUs (4+), RAM (8GB+, 16GB+ recommended), and disk space (80GB+, 100GB+ recommended).
6.  **Network Information**: You need the names of an internal network (`aio_network_name`) for the VM and an external network (`aio_external_network_name`) from which to allocate a floating IP.

## Usage Instructions

1.  Navigate to this directory: `cd 07-aio-deployer-with-osa-openstack`
2.  Copy the example variables file:
    `cp terraform.tfvars.example terraform.tfvars`
3.  Edit `terraform.tfvars` to match your OpenStack environment and preferences.
    **Crucially, set these required variables:**
    *   `aio_key_pair_name`
    *   `aio_network_name`
    *   `aio_external_network_name`
    Also review and adjust:
    *   `aio_image_name` (e.g., `"Ubuntu 22.04 LTS"`)
    *   `aio_flavor_name` (e.g., `"m1.xlarge"`)
    *   `aio_default_user` (if your image's default user isn't `ubuntu`)
    *   `aio_instance_password` (Only if you need password SSH. **WARNING: Security risk!**).
    *   `osa_branch` (e.g., `"stable/bobcat"` or the latest stable OSA release).
    *   OSA service enablement variables (`osa_enable_heat`, etc.).
4.  Initialize Terraform:
    `terraform init`
5.  Review the execution plan:
    `terraform plan`
6.  Apply the configuration to create the infrastructure:
    `terraform apply`
    Enter `yes` when prompted for confirmation.

## Post-Deployment

*   When `terraform apply` completes, the AIO VM will be created, and the `cloud-init` script will have started executing the OpenStack-Ansible installation in the background.
*   **The OSA installation process is lengthy** and can take anywhere from 30 minutes to several hours, depending on the VM's resources, network speed, and selected services.
*   You can monitor the installation progress by SSHing into the AIO VM and tailing the `cloud-init` log file specified in the Terraform outputs (`osa_aio_cloud_init_log_path`, typically `/var/log/cloud-init-osa-deploy.log`):
    ```bash
    # Get the floating IP from Terraform output
    FLOATING_IP=$(terraform output -raw aio_instance_floating_ip)
    DEFAULT_USER=$(terraform output -raw meta | jq -r .config.var.aio_default_user.value) # Or get from your tfvars
    # SSH into the instance (replace <private_key_path> with the path to your SSH private key)
    ssh -i <private_key_path> ${DEFAULT_USER}@${FLOATING_IP}

    # Once inside the VM:
    tail -f /var/log/cloud-init-osa-deploy.log
    ```
*   Upon successful completion of the OSA installation, the deployed OpenStack environment will be ready.
*   Terraform outputs will provide useful information like the Horizon URL (if enabled) and the path to the `admin-openrc.sh` file on the AIO VM.
*   To use the OpenStack CLI for your new AIO cloud, SSH into the AIO VM and source the `admin-openrc.sh` file:
    `source /etc/openstack_deploy/admin-openrc.sh`
    You can then use `openstack` commands.

## Cleaning Up

To destroy all resources created by this Terraform configuration:
`terraform destroy`
Enter `yes` when prompted.

## Important Considerations

*   **OSA Installation Duration**: Terraform provisions the VM and starts the `cloud-init` process. It does **not** wait for the full OSA installation to complete. Monitor the logs on the VM.
*   **Resource Consumption**: OSA AIO is resource-heavy. Ensure your underlying OpenStack cloud has sufficient quotas and capacity for the AIO VM.
*   **Base Image Compatibility**: The chosen base image (`aio_image_name`) must be compatible with OSA and have `cloud-init` support. Recent Ubuntu LTS or CentOS Stream versions are generally good choices.
*   **Password-based SSH**: While an option (`aio_instance_password`), it's a security risk. Strongly prefer SSH key-based authentication for production or shared environments.
*   **Debugging**: The primary log file for the OSA deployment process on the VM is `/var/log/cloud-init-osa-deploy.log`. Standard `cloud-init` logs (`/var/log/cloud-init.log`, `/var/log/cloud-init-output.log`) and OSA's own logs (often under `/var/log/ansible-osa/` or within `/opt/openstack-ansible/logs/`) are also crucial for troubleshooting.
*   **OSA Versioning**: OpenStack-Ansible is a rapidly evolving project. The `install_osa_aio.sh.tpl` script is based on common OSA practices but might require adjustments for very new or older OSA branches. Always consult the official OSA documentation for the specific branch you are using.

## Configuration File Overview

*   `provider.tf`: Configures the OpenStack provider.
*   `variables.tf`: Defines all input variables for the configuration.
*   `main.tf`: Contains the main OpenStack resources (instance, network components, security group, floating IP) and invokes the `user_data` script.
*   `outputs.tf`: Defines useful output values after deployment (instance IDs, IPs, SSH commands, log paths).
*   `terraform.tfvars.example`: An example variables file for users to copy and customize.
*   `README.md`: This documentation file.
*   `scripts/install_osa_aio.sh.tpl`: The Bash script template executed by `cloud-init` on the AIO VM to perform the OSA installation. It's populated with values from Terraform variables.