// --- General Settings ---
variable "prefix" {
  description = "A prefix to be used for naming created resources."
  type        = string
  default     = "tf-netfound"
}

// --- Network Configuration ---
variable "private_network_name" {
  description = "Name for the new private network."
  type        = string
  default     = "my-private-network"
}

variable "private_network_cidr" {
  description = "CIDR block for the new private network's subnet."
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_name" {
  description = "Name for the new private subnet."
  type        = string
  default     = "my-private-subnet"
}

variable "dns_nameservers" {
  description = "List of DNS nameservers for the subnet."
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"] // Google DNS, replace if needed
}

variable "router_name" {
  description = "Name for the new router."
  type        = string
  default     = "my-router"
}

variable "external_network_name" {
  description = "Name of an existing external network to connect the router to for internet access. This network should have a subnet providing floating IPs."
  type        = string
  // No default, must be provided by the user, e.g., "public", "ext-net"
}

// --- Security Group Configuration ---
variable "secgroup_name" {
  description = "Name for the security group."
  type        = string
  default     = "allow-ssh-ping"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block to allow SSH access from."
  type        = string
  default     = "0.0.0.0/0" // For wider access; restrict in production
}

// --- Instance Configuration ---
variable "instance_name" {
  description = "Name of the compute instance."
  type        = string
  default     = "test-vm-on-custom-net"
}

variable "image_name" {
  description = "Name of the image to use for the instance."
  type        = string
  default     = "Ubuntu 22.04" // Replace with a valid image name
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

variable "availability_zone" {
  description = "Availability zone for the instance."
  type        = string
  default     = "nova" // Or your specific AZ
}

variable "assign_floating_ip" {
  description = "Whether to assign a floating IP to the instance."
  type        = bool
  default     = true
}