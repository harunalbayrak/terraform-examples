variable "instance_name" {
  description = "Name for the instance"
  type        = string
  default     = "terraform-volume-instance"
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
  description = "Availability zone for deploying the instance and volume"
  type        = string
  default     = "nova"
}

variable "metadata" {
  description = "Metadata key/value pairs to assign to the instance"
  type        = map(string)
  default     = {}
}

# Volume specific variables
variable "volume_name" {
  description = "Name for the volume to be attached"
  type        = string
  default     = "terraform-data-volume"
}

variable "volume_size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Type of volume to create"
  type        = string
  default     = "ceph" # Common OpenStack volume type, adjust to match your environment
}

variable "volume_mount_point" {
  description = "Mount point for the volume on the instance"
  type        = string
  default     = "/data"
}

variable "volume_device" {
  description = "Device name for the volume on the instance"
  type        = string
  default     = "/dev/vdb"
}

variable "volume_filesystem" {
  description = "Filesystem to create on the volume"
  type        = string
  default     = "ext4"
}

variable "floating_ip_pool" {
  description = "Pool to allocate floating IP from"
  type        = string
  default     = "external" # Adjust to match your environment
}