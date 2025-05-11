variable "instance_name" {
  description = "Name of the compute instance."
  type        = string
  default     = "multi-network-instance"
}

variable "image_name" {
  description = "Name of the image to use for the instance."
  type        = string
  default     = "Ubuntu 22.04" // Replace with a valid image name in your OpenStack
}

variable "flavor_name" {
  description = "Name of the flavor to use for the instance."
  type        = string
  default     = "m1.small" // Replace with a valid flavor name
}

variable "key_pair_name" {
  description = "Name of the SSH key pair to use for the instance."
  type        = string
  // No default, should be provided by the user
}

variable "network_names" {
  description = "A list of network names to attach the instance to."
  type        = list(string)
  default     = ["private-network-1", "private-network-2"] // Replace with valid network names
  validation {
    condition     = length(var.network_names) >= 1
    error_message = "At least one network name must be provided."
  }
}

variable "security_groups" {
  description = "A list of security group names to associate with the instance."
  type        = list(string)
  default     = ["default"] // Or a custom security group allowing SSH
}

variable "availability_zone" {
  description = "Availability zone for the instance."
  type        = string
  default     = "nova" // Or your specific AZ
}

variable "assign_floating_ip" {
  description = "Whether to assign a floating IP to the instance's first network interface."
  type        = bool
  default     = false
}

variable "floating_ip_pool" {
  description = "Name of the floating IP pool to use if assign_floating_ip is true."
  type        = string
  default     = "public" // Or your external network name
}