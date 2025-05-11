variable "instance_basename" {
  description = "Base name for the compute instances. A number will be appended."
  type        = string
  default     = "lb-member-vm"
}

variable "instance_count" {
  description = "Number of instances to create behind the load balancer."
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
  description = "Name of the network to attach the instances and the load balancer VIP to."
  type        = string
  // No default, user must specify the network they want to use.
  // e.g., "private-network"
}

variable "subnet_name" {
  description = "Name of the subnet (within the specified network) for the load balancer VIP and instance IPs."
  type        = string
  // No default, user must specify the subnet.
  // e.g., "private-subnet"
}

variable "instance_sg_name" {
  description = "Name for the security group for the instances."
  type        = string
  default     = "lb-instance-sg"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block to allow SSH access from to the instances."
  type        = string
  default     = "0.0.0.0/0" // For wider access; restrict in production
}

variable "http_allowed_cidr" {
  description = "CIDR block to allow HTTP access from to the instances. Typically the LB's subnet or all if LB FIP is used."
  type        = string
  default     = "0.0.0.0/0" // Allows direct access and LB access
}

variable "lb_name" {
  description = "Name for the load balancer."
  type        = string
  default     = "my-web-lb"
}

variable "lb_listener_port" {
  description = "Port the load balancer listener will listen on."
  type        = number
  default     = 80
}

variable "lb_pool_member_port" {
  description = "Port the backend instances are listening on (e.g., for Apache/Nginx)."
  type        = number
  default     = 80
}

variable "assign_lb_floating_ip" {
  description = "Whether to assign a floating IP to the load balancer VIP."
  type        = bool
  default     = true
}

variable "floating_ip_pool" {
  description = "Name of the floating IP pool to use if assign_lb_floating_ip is true."
  type        = string
  default     = "public" // Or your external network name
}

variable "availability_zone" {
  description = "Availability zone for the instances."
  type        = string
  default     = "nova" // Or your specific AZ
}