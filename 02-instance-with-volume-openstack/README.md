# OpenStack Instance with Volume using Terraform

This example demonstrates how to create an OpenStack compute instance with an attached persistent volume using Terraform. The configuration includes:

- Creating a compute instance
- Creating a persistent volume
- Attaching the volume to the instance
- Formatting and mounting the volume automatically
- Setting up persistent mount across reboots
- Configuring basic security with a security group
- Allocating and associating a floating IP

## Prerequisites

- Terraform v1.5.0 or newer
- Valid OpenStack credentials
- SSH key pair already created in OpenStack
- SSH private key accessible locally to run the volume setup script

## Provider Configuration

This example uses environment variables for OpenStack authentication. Before running Terraform commands, make sure to source your OpenStack RC file:

```bash
source your-openstack-rc.sh
```

Common environment variables needed:
- `OS_AUTH_URL`
- `OS_USERNAME`
- `OS_PASSWORD`
- `OS_TENANT_NAME` or `OS_PROJECT_NAME`
- `OS_REGION_NAME`

## Required Input Variables

Copy the `terraform.tfvars.example` file to `terraform.tfvars` and adjust the values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

At minimum, you must specify:
- `image_id`: ID of the image to use for the instance
- `network_name`: Name of the network to attach to the instance
- `key_pair`: Name of your SSH key pair

## SSH Key Setup

This example uses SSH to connect to the instance and run the volume setup script. Make sure:

1. The specified OpenStack key pair exists
2. The corresponding private key is accessible locally
3. Update the path to your private key in `main.tf` if it's not at `~/.ssh/id_rsa`

## Volume Configuration

The example creates a persistent volume with the following default settings:
- 10GB size
- ext4 filesystem
- Mounted at `/data`

You can adjust these settings in your `terraform.tfvars` file.

## Usage

Initialize the Terraform configuration:

```bash
terraform init
```

Review the execution plan:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform validate
terraform apply
```

## How It Works

1. An instance and a volume are created in OpenStack
2. The volume is attached to the instance
3. A floating IP is allocated and associated with the instance
4. Terraform connects to the instance using SSH
5. The `setup_volume.sh` script formats and mounts the volume
6. The script configures `/etc/fstab` for persistent mounting

## Accessing the Instance and Volume

After a successful deployment, you can:

1. SSH into the instance using the provided command in the output
2. Check that the volume is mounted properly with the provided command
3. Access your data at the specified mount point (default: `/data`)

## Clean Up

To destroy the resources created by this configuration:

```bash
terraform destroy
```

## Security Considerations

This example creates a security group with SSH access allowed from any IP address (0.0.0.0/0). In a production environment, you should restrict SSH access to specific IP ranges.

## Customizing the Volume Setup

The volume setup script (`scripts/setup_volume.sh`) can be modified to:
- Use different filesystem types
- Set different permissions
- Create additional directories or files on the volume
- Execute additional setup commands

## Troubleshooting

If the volume doesn't mount properly:
1. Check the logs at `/var/log/volume_setup.log` on the instance
2. Verify that the device path (`/dev/vdb` by default) is correct
3. Make sure the instance has proper permissions to format and mount the volume