output "private_network_id" {
  description = "ID of the created private network."
  value       = openstack_networking_network_v2.private_network.id
}

output "private_network_name" {
  description = "Name of the created private network."
  value       = openstack_networking_network_v2.private_network.name
}

output "private_subnet_id" {
  description = "ID of the created private subnet."
  value       = openstack_networking_subnet_v2.private_subnet.id
}

output "private_subnet_cidr" {
  description = "CIDR of the created private subnet."
  value       = openstack_networking_subnet_v2.private_subnet.cidr
}

output "router_id" {
  description = "ID of the created router."
  value       = openstack_networking_router_v2.router.id
}

output "router_name" {
  description = "Name of the created router."
  value       = openstack_networking_router_v2.router.name
}

output "security_group_id" {
  description = "ID of the created security group."
  value       = openstack_networking_secgroup_v2.secgroup.id
}

output "instance_id" {
  description = "ID of the created instance."
  value       = openstack_compute_instance_v2.instance.id
}

output "instance_name" {
  description = "Name of the created instance."
  value       = openstack_compute_instance_v2.instance.name
}

output "instance_fixed_ip" {
  description = "Fixed IP address of the instance in the private network."
  value       = openstack_compute_instance_v2.instance.access_ip_v4
}

output "instance_floating_ip" {
  description = "Floating IP address assigned to the instance, if any."
  value       = var.assign_floating_ip && length(openstack_networking_floatingip_v2.fip) > 0 ? openstack_networking_floatingip_v2.fip[0].address : "N/A"
}

output "ssh_command" {
  description = "SSH command to connect to the instance (assuming Ubuntu image and floating IP)."
  value       = var.assign_floating_ip && length(openstack_networking_floatingip_v2.fip) > 0 ? "ssh ubuntu@${openstack_networking_floatingip_v2.fip[0].address}" : "SSH command not available (no floating IP assigned or using a different user)."
  sensitive   = false
}