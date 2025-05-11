# Terraform Examples

A collection of practical Terraform examples for provisioning and managing infrastructure on OpenStack.

## Overview

This repository contains modular, reusable Terraform code examples for OpenStack deployments. Each example is self-contained and demonstrates a specific infrastructure pattern or use case.

## Examples

| Name | Description |
|------|-------------|
| [01-sample-instance-openstack](./01-sample-instance-openstack/) | Basic instance provisioning with security groups and a startup script |
| [02-instance-with-volume-openstack](./02-instance-with-volume-openstack/) | Instance with attached persistent volume |
| [03-instance-with-multiple-networks-openstack](./03-instance-with-multiple-networks-openstack/) | Instance connected to multiple networks |
| [04-instance-with-loadbalancer-openstack](./04-instance-with-loadbalancer-openstack/) | Multiple instances behind a load balancer |
| [05-instance-with-server-group-openstack](./05-instance-with-server-group-openstack/) | Instance with server group |
| [06-networking-foundations-openstack](./06-networking-foundations-openstack/) | Networking foundations for Openstack |
| [07-aio-deployer-with-osa-openstack](./07-aio-deployer-with-osa-openstack/) | Openstack-Ansible AIO Deployer |

## Getting Started

### Prerequisites

- Terraform v1.5.0 or newer
- Valid OpenStack credentials
- Basic understanding of Terraform and OpenStack concepts

### Authentication

Before running any examples, ensure you have sourced your OpenStack RC file:

```bash
source your-openstack-rc.sh
```

Alternatively, you can provide credentials via environment variables:

```bash
export OS_AUTH_URL="https://your-openstack-auth-url:5000/v3"
export OS_PROJECT_NAME="your-project"
export OS_USERNAME="your-username"
export OS_PASSWORD="your-password"
export OS_REGION_NAME="your-region"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
```

### Using the Examples

Each example directory contains its own README with specific instructions. The general workflow is:

1. Navigate to the example directory
2. Copy the terraform.tfvars.example file to terraform.tfvars
3. Edit the terraform.tfvars file to match your environment
4. Initialize Terraform
5. Apply the configuration

Example:

```bash
cd 01-sample-instance-openstack
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your desired values
terraform init
terraform plan
terraform apply
```

## Structure

Each example follows a consistent structure:

```
example-name/
├── main.tf           # Main configuration file
├── variables.tf      # Input variables
├── outputs.tf        # Output definitions
├── provider.tf       # Provider configuration
├── scripts/          # Scripts for instance configuration
└── README.md         # Example documentation
```

## Best Practices

These examples implement several Terraform best practices:

- **Modularity**: Code is separated into logical files
- **Readability**: Consistent formatting and naming conventions
- **Documentation**: Comprehensive README files and code comments
- **Variable Parameterization**: Flexible configurations through variables
- **Output Exposure**: Useful outputs for integration with other systems

## Customization

Feel free to customize these examples to fit your specific needs. The modular structure makes it easy to add or remove components as required.

## Contribution

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.