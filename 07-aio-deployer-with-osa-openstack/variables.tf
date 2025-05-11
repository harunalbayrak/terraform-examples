variable "aio_instance_name" {
  description = "Name for the All-In-One (AIO) OpenStack instance."
  type        = string
  default     = "osa-aio-server"
}

variable "aio_image_name" {
  description = "Name of the image to use for the AIO instance (e.g., 'Ubuntu 22.04 LTS', 'CentOS Stream 9')."
  type        = string
  default     = "Ubuntu 22.04 LTS" # Adjust to a suitable image in your OpenStack environment
}

variable "aio_flavor_name" {
  description = "Name of the flavor for the AIO instance. Should be reasonably powerful (e.g., 4+ vCPU, 8GB+ RAM, 80GB+ Disk)."
  type        = string
  default     = "m1.large" # Example: 4 vCPU, 8GB RAM, 80GB Disk. Adjust as needed.
}

variable "aio_key_pair_name" {
  description = "Name of the SSH key pair to use for the AIO instance."
  type        = string
  # No default, user must provide this.
}

variable "aio_network_name" {
  description = "Name of the network to attach the AIO instance to."
  type        = string
  # No default, user must provide this.
}

variable "aio_external_network_name" {
  description = "Name of the external network for allocating a floating IP."
  type        = string
  # No default, user must provide this.
}

variable "aio_availability_zone" {
  description = "Availability zone for the AIO instance."
  type        = string
  default     = null # Let OpenStack decide if not specified
}

variable "aio_default_user" {
  description = "Default username for the cloud image (e.g., 'ubuntu', 'centos', 'cloud-user'). Used for SSH password setup if enabled."
  type        = string
  default     = "ubuntu" # Common for Ubuntu images
}

variable "aio_instance_password" {
  description = "Password for the default user on the AIO instance. Used for initial SSH access if needed. WARNING: Use with extreme caution. Key-based auth is preferred."
  type        = string
  sensitive   = true
  default     = null # Do not set a default password. Provide via tfvars if absolutely necessary.
}

variable "aio_security_group_ports" {
  description = "List of TCP ports to open in the dynamically created security group for the AIO instance."
  type        = list(number)
  default     = [22, 80, 443, 5000, 6080, 8774, 8776, 9292, 9696]
  # Common ports: SSH, HTTP, HTTPS, Keystone, Horizon (VNC), Nova, Cinder, Glance, Neutron
}

variable "aio_root_disk_size_gb" {
  description = "Size of the root disk in GB for the AIO instance. Only applicable if the image and flavor allow resizing. OSA AIO requires significant disk space."
  type        = number
  default     = 100 # OSA can be disk-intensive, 80-100GB is a good start.
}

variable "aio_tags" {
  description = "Tags to apply to the AIO instance."
  type        = map(string)
  default = {
    environment = "development"
    project     = "osa-aio-deployment"
    owner       = "change-me@example.com"
  }
}

# --- OpenStack-Ansible Specific Variables ---
variable "osa_branch" {
  description = "OpenStack-Ansible branch or tag to checkout (e.g., 'stable/bobcat', 'master'). Check OSA docs for latest stable."
  type        = string
  default     = "stable/bobcat" # Example: 2023.2 release. Update as needed.
}

variable "osa_environment_layout" {
  description = "OSA environment layout to use. 'aio' is typical for All-In-One."
  type        = string
  default     = "aio"
}

variable "osa_scenario" {
  description = "The OSA scenario to deploy (e.g., 'base', 'network_lvm', 'storage_ceph'). 'base' is a good start for AIO."
  type        = string
  default     = "base" # A simple scenario, can be customized.
}

variable "osa_infra_provider" {
  description = "The infrastructure provider for OSA (e.g., 'lxc', 'metal'). 'lxc' is common for AIO."
  type        = string
  default     = "lxc"
}

# OSA Service Enablement (these are standard OSA variables)
variable "osa_enable_heat" {
  description = "Enable Heat (orchestration) service in OSA."
  type        = bool
  default     = true
}

variable "osa_enable_cinder" {
  description = "Enable Cinder (block storage) service in OSA."
  type        = bool
  default     = true
}

variable "osa_enable_neutron" {
  description = "Enable Neutron (networking) service in OSA."
  type        = bool
  default     = true
}

variable "osa_enable_swift" {
  description = "Enable Swift (object storage) service in OSA. May require extra configuration for loopback devices in AIO."
  type        = bool
  default     = false # Swift AIO with loopback can be tricky; start with false.
}

variable "osa_enable_horizon" {
  description = "Enable Horizon (dashboard) service in OSA."
  type        = bool
  default     = true
}

variable "osa_bootstrap_ansible_pip_packages" {
  description = "Additional pip packages to install during bootstrap-ansible.sh (e.g., 'python-openstackclient')."
  type        = list(string)
  default     = ["python-openstackclient", "python-heatclient"]
}