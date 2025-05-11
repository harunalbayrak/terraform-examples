output "server_group_id" {
  description = "The ID of the created server group."
  value       = openstack_compute_servergroup_v2.app_server_group.id
}

output "server_group_name" {
  description = "The name of the created server group."
  value       = openstack_compute_servergroup_v2.app_server_group.name
}

output "server_group_policy" {
  description = "The policy applied to the server group."
  value       = openstack_compute_servergroup_v2.app_server_group.policies[0]
}

output "instance_ids" {
  description = "List of IDs of the created instances."
  value       = openstack_compute_instance_v2.app_instance[*].id
}

output "instance_names" {
  description = "List of names of the created instances."
  value       = openstack_compute_instance_v2.app_instance[*].name
}

output "instance_fixed_ips" {
  description = "List of fixed IP addresses of the instances."
  value       = [for instance in openstack_compute_instance_v2.app_instance : instance.access_ip_v4]
}

output "first_instance_floating_ip" {
  description = "The floating IP address assigned to the first instance, if any."
  value       = var.assign_floating_ip_to_first_instance && var.instance_count > 0 && length(openstack_networking_floatingip_v2.fip_instance_0) > 0 ? openstack_networking_floatingip_v2.fip_instance_0[0].address : "N/A"
}

output "ssh_command_first_instance" {
  description = "SSH command to connect to the first instance (assuming Ubuntu image and floating IP)."
  value       = var.assign_floating_ip_to_first_instance && var.instance_count > 0 && length(openstack_networking_floatingip_v2.fip_instance_0) > 0 ? "ssh ubuntu@${openstack_networking_floatingip_v2.fip_instance_0[0].address}" : "SSH command not available (no floating IP or using a different user)."
  sensitive   = false
}

output "instance_security_group_id" {
  description = "ID of the security group created for the instances."
  value       = openstack_networking_secgroup_v2.instance_sg.id
}