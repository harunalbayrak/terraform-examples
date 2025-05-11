# Data source to get network ID from network name
data "openstack_networking_network_v2" "instance_network" {
  name = var.network_name
}

# Create a security group for the instance
resource "openstack_networking_secgroup_v2" "instance_secgroup" {
  name        = "${var.instance_name}-secgroup"
  description = "Security group for ${var.instance_name}"
}

# Add SSH access rule
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.instance_secgroup.id
}

# Add HTTP access rule
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.instance_secgroup.id
}

# Add HTTPS access rule
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.instance_secgroup.id
}

# Create an OpenStack compute instance
resource "openstack_compute_instance_v2" "basic_instance" {
  name            = var.instance_name
  image_id        = var.image_id
  flavor_name     = var.flavor_name
  key_pair        = var.key_pair
  security_groups = concat([openstack_networking_secgroup_v2.instance_secgroup.name], var.security_groups)
  
  # Assign network to the instance
  network {
    uuid = data.openstack_networking_network_v2.instance_network.id
  }
  
  # Set availability zone
  availability_zone = var.availability_zone
  
  # Set metadata
  metadata = merge(
    {
      created_by = "terraform"
    },
    var.metadata
  )
  
  # User data script that runs on instance boot
  user_data = file("${path.module}/scripts/startup.sh")
}

# Create a floating IP (optional)
resource "openstack_networking_floatingip_v2" "instance_fip" {
  pool = "external"  # Use your external network name
}

# Associate floating IP with the instance
resource "openstack_compute_floatingip_associate_v2" "instance_fip_association" {
  floating_ip = openstack_networking_floatingip_v2.instance_fip.address
  instance_id = openstack_compute_instance_v2.basic_instance.id
}
