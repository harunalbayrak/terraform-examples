output "instance_id" {
  description = "ID of the created instance"
  value       = openstack_compute_instance_v2.basic_instance.id
}

output "instance_name" {
  description = "Name of the created instance"
  value       = openstack_compute_instance_v2.basic_instance.name
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = openstack_compute_instance_v2.basic_instance.access_ip_v4
}

output "floating_ip" {
  description = "Floating IP address associated with the instance"
  value       = openstack_networking_floatingip_v2.instance_fip.address
}

output "instance_status" {
  description = "Current status of the instance"
  value       = openstack_compute_instance_v2.basic_instance.power_state
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/your_key.pem ubuntu@${openstack_networking_floatingip_v2.instance_fip.address}"
}

output "web_url" {
  description = "URL for the web server installed by the startup script"
  value       = "http://${openstack_networking_floatingip_v2.instance_fip.address}"
}

output "security_group_id" {
  description = "ID of the security group created for the instance"
  value       = openstack_networking_secgroup_v2.instance_secgroup.id
}