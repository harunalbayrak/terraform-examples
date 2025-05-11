variable "instance_basename" {
  description = "Base name for the compute instances. A number will be appended."
  type        = string
  default     = "sg-member-vm"
}

variable "instance_count" {
  description = "Number of instances to create in the server group."
  type        = number
  default     = 2
  validation {
    condition     = var.instance_count >= 1
    error_message = "At least one instance must be created."
  }
}

variable "image_name" {
  description = "Name of the image to use for the instances."
  type        = string
  default     = "Ubuntu 22.04" // Replace with a valid image name
}

variable "flavor_name" {
  description = "Name of the flavor to use for the instances."
  type        = string
  default     = "m1.small" // Replace with a valid flavor name
}

variable "key_pair_name" {
  description = "Name of the SSH key pair to use for the instances."
  type        = string
  // No default, should be provided by the user
}

variable "network_name" {
  description = "Name of the network to attach the instances to."
  type        = string
  // No default, user must specify the network.
  // e.g., "private-network"
}

variable "security_group_name" {
  description = "Name for the security group for the instances."
  type        = string
  default     = "sg-instance-sg"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block to allow SSH access from to the instances."
  type        = string
  default     = "0.0.0.0/0" // For wider access; restrict in production
}

variable "server_group_name" {
  description = "Name for the server group."
  type        = string
  default     = "my-app-server-group"
}

variable "server_group_policy" {
  description = "Policy for the server group (e.g., 'anti-affinity', 'affinity', 'soft-anti-affinity', 'soft-affinity')."
  type        = string
  default     = "anti-affinity"
  validation {
    condition     = contains(["anti-affinity", "affinity", "soft-anti-affinity", "soft-affinity"], var.server_group_policy)
    error_message = "Valid server group policies are 'anti-affinity', 'affinity', 'soft-anti-affinity', 'soft-affinity'."
  }
}

variable "availability_zone" {
  description = "Availability zone for the instances."
  type        = string
  default     = "nova" // Or your specific AZ
}

variable "assign_floating_ip_to_first_instance" {
  description = "Whether to assign a floating IP to the first instance in the group."
  type        = bool
  default     = false
}

variable "floating_ip_pool" {
  description = "Name of the floating IP pool to use if assigning a floating IP."
  type        = string
  default     = "public" // Or your external network name
}