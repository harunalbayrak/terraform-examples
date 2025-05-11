// --- Data Source for External Network ---
data "openstack_networking_network_v2" "external_network" {
  name = var.external_network_name
}

// --- 1. Private Network ---
resource "openstack_networking_network_v2" "private_network" {
  name           = "${var.prefix}-${var.private_network_name}"
  admin_state_up = "true"
  tags           = ["terraform-managed", "environment:example"]
}

// --- 2. Private Subnet ---
resource "openstack_networking_subnet_v2" "private_subnet" {
  name            = "${var.prefix}-${var.private_subnet_name}"
  network_id      = openstack_networking_network_v2.private_network.id
  cidr            = var.private_network_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
  tags            = ["terraform-managed", "environment:example"]
}

// --- 3. Router ---
resource "openstack_networking_router_v2" "router" {
  name                = "${var.prefix}-${var.router_name}"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_network.id
  tags                = ["terraform-managed", "environment:example"]
}

// --- 4. Router Interface (connecting router to private subnet) ---
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
  depends_on = [
    openstack_networking_router_v2.router,
    openstack_networking_subnet_v2.private_subnet
  ]
}

// --- 5. Security Group ---
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "${var.prefix}-${var.secgroup_name}"
  description = "Allows SSH and ICMP traffic"
  tags        = ["terraform-managed", "environment:example"]
}

// Allow SSH
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = var.ssh_allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

// Allow ICMP (ping)
resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

// --- 6. Compute Instance ---
// Data source for the image
data "openstack_images_image_v2" "instance_image" {
  name        = var.image_name
  most_recent = true
}

// Data source for the flavor
data "openstack_compute_flavor_v2" "instance_flavor" {
  name = var.flavor_name
}

resource "openstack_compute_instance_v2" "instance" {
  name              = "${var.prefix}-${var.instance_name}"
  image_id          = data.openstack_images_image_v2.instance_image.id
  flavor_id         = data.openstack_compute_flavor_v2.instance_flavor.id
  key_pair          = var.key_pair_name
  security_groups   = [openstack_networking_secgroup_v2.secgroup.name]
  availability_zone = var.availability_zone

  network {
    uuid = openstack_networking_network_v2.private_network.id
  }

  depends_on = [
    openstack_networking_router_interface_v2.router_interface, // Ensure network is fully routable
    openstack_networking_secgroup_v2.secgroup
  ]
  tags = ["terraform-managed", "environment:example"]
}

// --- 7. Optional Floating IP ---
resource "openstack_networking_floatingip_v2" "fip" {
  count = var.assign_floating_ip ? 1 : 0
  pool  = data.openstack_networking_network_v2.external_network.name // Use the name of the external network as the pool
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  count       = var.assign_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  instance_id = openstack_compute_instance_v2.instance.id
}