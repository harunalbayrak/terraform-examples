output "instance_id" {
  description = "ID of the created instance"
  value       = openstack_compute_instance_v2.instance_with_volume.id
}

output "instance_name" {
  description = "Name of the created instance"
  value       = openstack_compute_instance_v2.instance_with_volume.name
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = openstack_compute_instance_v2.instance_with_volume.access_ip_v4
}

output "floating_ip" {
  description = "Floating IP address associated with the instance"
  value       = openstack_networking_floatingip_v2.instance_fip.address
}

output "volume_id" {
  description = "ID of the created and attached volume"
  value       = openstack_blockstorage_volume_v3.data_volume.id
}

output "volume_name" {
  description = "Name of the created volume"
  value       = openstack_blockstorage_volume_v3.data_volume.name
}

output "volume_size" {
  description = "Size of the created volume in GB"
  value       = openstack_blockstorage_volume_v3.data_volume.size
}

output "volume_mount_point" {
  description = "Mount point of the volume on the instance"
  value       = var.volume_mount_point
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${openstack_networking_floatingip_v2.instance_fip.address}"
}

output "check_volume_command" {
  description = "Command to check the mounted volume on the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${openstack_networking_floatingip_v2.instance_fip.address} 'df -h ${var.volume_mount_point}'"
}