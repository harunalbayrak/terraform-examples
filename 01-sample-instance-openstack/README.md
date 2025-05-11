# Basic OpenStack Instance with Terraform

This example demonstrates how to create a basic compute instance in OpenStack using Terraform. The configuration includes:

- Creating a single compute instance
- Creating and configuring security groups with appropriate rules
- Configuring network connectivity
- Allocating and associating a floating IP
- Setting up basic metadata
- Running a startup script that installs and configures nginx

## Prerequisites

- Terraform v1.5.0 or newer
- Valid OpenStack credentials
- SSH key pair already created in OpenStack

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

## Accessing the Instance

After a successful deployment, the output will include:
- The instance ID and name
- The private IP address
- The public (floating) IP address
- A ready-to-use SSH command

You can use the provided SSH command to connect to the instance:

```bash
ssh -i ~/.ssh/your_key.pem ubuntu@<FLOATING_IP>
```

Replace `ubuntu` with the appropriate username for your selected image.

## Clean Up

To destroy the resources created by this configuration:

```bash
terraform destroy
```

## Additional Notes

- The floating IP association relies on an external network named "external". You may need to modify this based on your OpenStack environment's configuration.
- A custom security group is created with rules for SSH (port 22), HTTP (port 80), and HTTPS (port 443).
- The default security group is also attached to the instance in addition to the custom security group.
- The startup script installs nginx and creates a basic web page, which you can access at http://<FLOATING_IP> after deployment.

## Security Group

This example creates a dedicated security group with the following rules:
- SSH (TCP port 22) - Allow from anywhere
- HTTP (TCP port 80) - Allow from anywhere
- HTTPS (TCP port 443) - Allow from anywhere

You can modify these rules in the `main.tf` file according to your security requirements.

## Startup Script

The instance uses a startup script located in the `scripts/startup.sh` file, which:
1. Updates system packages
2. Installs common tools and nginx
3. Creates a basic webpage
4. Configures the firewall

You can modify this script to customize the initial configuration of your instance.