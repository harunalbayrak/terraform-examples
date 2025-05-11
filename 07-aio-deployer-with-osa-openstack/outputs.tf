output "aio_instance_id" {
  description = "ID of the deployed OSA AIO instance."
  value       = openstack_compute_instance_v2.aio_server.id
}

output "aio_instance_fixed_ip" {
  description = "Fixed (private) IP address of the OSA AIO instance."
  value       = openstack_compute_instance_v2.aio_server.network[0].fixed_ip_v4 # Assumes first network interface
}

output "aio_instance_floating_ip" {
  description = "Floating (public) IP address associated with the OSA AIO instance."
  value       = openstack_networking_floatingip_v2.aio_fip.address
  depends_on  = [openstack_networking_floatingip_associate_v2.aio_fip_assoc]
}

output "aio_ssh_command_with_key" {
  description = "SSH command to connect to the AIO instance using your SSH key. Replace <private_key_path> and <username> (e.g., ubuntu, centos)."
  value       = "ssh -i <private_key_path> ${var.aio_default_user}@${openstack_networking_floatingip_v2.aio_fip.address}"
}

output "aio_ssh_command_with_password" {
  description = "SSH command to connect to the AIO instance using password (if configured and enabled). Use with caution."
  value = (var.aio_instance_password != null && var.aio_instance_password != ""
    ? "ssh ${var.aio_default_user}@${openstack_networking_floatingip_v2.aio_fip.address} (Password: ${var.aio_instance_password})"
  : "Password-based SSH is not configured or disabled for this instance.")
  sensitive   = true # Contains password if set
}

output "osa_aio_cloud_init_log_path" {
  description = "Path to the cloud-init OSA deployment log file on the AIO instance."
  value       = "/var/log/cloud-init-osa-deploy.log"
}

output "osa_aio_horizon_url" {
  description = "URL for the Horizon dashboard (if enabled and deployment is successful)."
  value       = var.osa_enable_horizon ? "http://${openstack_networking_floatingip_v2.aio_fip.address}/horizon" : "Horizon dashboard is not enabled via osa_enable_horizon variable."
}

output "osa_aio_openrc_file_path" {
  description = "Path to the admin openrc file on the AIO instance for OpenStack CLI access to the deployed cloud."
  value       = "/etc/openstack_deploy/admin-openrc.sh"
}

output "instructions_for_monitoring_deployment" {
  description = "To monitor the OSA deployment, SSH into the instance and tail the log file."
  value       = "After SSHing into the instance (see 'aio_ssh_command_with_key'), run: tail -f /var/log/cloud-init-osa-deploy.log"
}