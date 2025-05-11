output "instance_ids" {
  description = "List of IDs of the created instances."
  value       = openstack_compute_instance_v2.app_instance[*].id
}

output "instance_fixed_ips" {
  description = "List of fixed IP addresses of the instances."
  value       = openstack_compute_instance_v2.app_instance[*].access_ip_v4
}

output "instance_ssh_commands" {
  description = "Example SSH commands to connect to each instance (if they had floating IPs, for direct access if needed - not the LB FIP)."
  value       = [for i in range(var.instance_count) : "ssh ubuntu@${openstack_compute_instance_v2.app_instance[i].access_ip_v4} # (Assuming 'ubuntu' user and direct network access or bastion)"]
  // Note: Direct SSH might require floating IPs on instances or bastion host.
}

output "loadbalancer_id" {
  description = "The ID of the created load balancer."
  value       = openstack_lb_loadbalancer_v2.web_lb.id
}

output "loadbalancer_vip_address" {
  description = "The VIP address of the load balancer on the internal network."
  value       = openstack_lb_loadbalancer_v2.web_lb.vip_address
}

output "loadbalancer_floating_ip" {
  description = "The floating IP address assigned to the load balancer, if any."
  value       = var.assign_lb_floating_ip ? openstack_networking_floatingip_v2.lb_fip[0].address : "N/A"
}

output "loadbalancer_access_url" {
  description = "URL to access the load balanced application (if FIP is assigned and listener is on port 80)."
  value       = var.assign_lb_floating_ip && var.lb_listener_port == 80 ? "http://${openstack_networking_floatingip_v2.lb_fip[0].address}" : (var.lb_listener_port == 80 ? "http://${openstack_lb_loadbalancer_v2.web_lb.vip_address} (Access via internal network or VPN)" : "Access via ${var.assign_lb_floating_ip ? openstack_networking_floatingip_v2.lb_fip[0].address : openstack_lb_loadbalancer_v2.web_lb.vip_address}:${var.lb_listener_port}")
}

output "instance_security_group_id" {
  description = "ID of the security group created for the instances."
  value       = openstack_networking_secgroup_v2.instance_sg.id
}