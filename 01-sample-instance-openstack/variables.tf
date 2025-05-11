variable "instance_name" {
  description = "Name for the instance"
  type        = string
  default     = "terraform-instance"
}

variable "image_id" {
  description = "ID of the image to use for the instance"
  type        = string
  # No default as this is environment-specific
}

variable "flavor_name" {
  description = "Name of the flavor for the instance"
  type        = string
  default     = "m1.small"
}

variable "key_pair" {
  description = "SSH key pair to use for the instance"
  type        = string
  # No default as this is user-specific
}

variable "security_groups" {
  description = "List of security groups for the instance"
  type        = list(string)
  default     = ["default"]
}

variable "network_name" {
  description = "Name of the network to connect the instance"
  type        = string
  # No default as this is environment-specific
}

variable "availability_zone" {
  description = "Availability zone for deploying the instance"
  type        = string
  default     = "nova"
}

variable "metadata" {
  description = "Metadata key/value pairs to assign to the instance"
  type        = map(string)
  default     = {}
}