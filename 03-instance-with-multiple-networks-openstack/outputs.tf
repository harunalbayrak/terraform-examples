output "instance_id" {
  description = "The ID of the created instance."
  value       = openstack_compute_instance_v2.multi_net_instance.id
}

output "instance_name" {
  description = "The name of the created instance."
  value       = openstack_compute_instance_v2.multi_net_instance.name
}

output "instance_networks" {
  description = "Network information for the instance, including fixed IPs for each attached network."
  value       = openstack_compute_instance_v2.multi_net_instance.network
}

output "instance_access_ip_v4" {
  description = "The first accessible IPv4 address of the instance (often the first fixed IP or floating IP if assigned)."
  value       = openstack_compute_instance_v2.multi_net_instance.access_ip_v4
}

output "instance_floating_ip" {
  description = "The floating IP address assigned to the instance, if any."
  value       = var.assign_floating_ip ? openstack_networking_floatingip_v2.fip[0].address : "N/A"
}

output "ssh_command" {
  description = "SSH command to connect to the instance (assuming Ubuntu image and floating IP)."
  value       = var.assign_floating_ip && openstack_networking_floatingip_v2.fip[0].address != "" ? "ssh ubuntu@${openstack_networking_floatingip_v2.fip[0].address}" : "SSH command not available (no floating IP or using a different user)."
  sensitive   = false // Set to true if key path is included
}