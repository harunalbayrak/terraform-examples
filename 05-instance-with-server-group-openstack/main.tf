// --- Network Data ---
data "openstack_networking_network_v2" "instance_network" {
  name = var.network_name
}

// --- Image and Flavor Data ---
data "openstack_images_image_v2" "instance_image" {
  name        = var.image_name
  most_recent = true
}

data "openstack_compute_flavor_v2" "instance_flavor" {
  name = var.flavor_name
}

// --- Security Group for Instances ---
resource "openstack_networking_secgroup_v2" "instance_sg" {
  name        = var.security_group_name
  description = "Security group for instances in a server group"
}

// Allow SSH
resource "openstack_networking_secgroup_rule_v2" "instance_sg_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.instance_sg.id
}

// --- Server Group ---
resource "openstack_compute_servergroup_v2" "app_server_group" {
  name     = var.server_group_name
  policies = [var.server_group_policy] // Policies must be a list
}

// --- Compute Instances ---
resource "openstack_compute_instance_v2" "app_instance" {
  count             = var.instance_count
  name              = "${var.instance_basename}-${count.index + 1}"
  image_id          = data.openstack_images_image_v2.instance_image.id
  flavor_id         = data.openstack_compute_flavor_v2.instance_flavor.id
  key_pair          = var.key_pair_name
  security_groups   = [openstack_networking_secgroup_v2.instance_sg.name]
  availability_zone = var.availability_zone
  // user_data      = file("${path.module}/scripts/user-data.sh") // Optional user data

  network {
    uuid = data.openstack_networking_network_v2.instance_network.id
  }

  scheduler_hints {
    group = openstack_compute_servergroup_v2.app_server_group.id
  }

  depends_on = [
    openstack_compute_servergroup_v2.app_server_group,
    openstack_networking_secgroup_v2.instance_sg
  ]
}

// --- Optional: Floating IP for the first instance ---
resource "openstack_networking_floatingip_v2" "fip_instance_0" {
  count = var.assign_floating_ip_to_first_instance && var.instance_count > 0 ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate_instance_0" {
  count       = var.assign_floating_ip_to_first_instance && var.instance_count > 0 ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip_instance_0[0].address
  instance_id = openstack_compute_instance_v2.app_instance[0].id
}