// Data source for the image
data "openstack_images_image_v2" "instance_image" {
  name        = var.image_name
  most_recent = true
}

// Data source for the flavor
data "openstack_compute_flavor_v2" "instance_flavor" {
  name = var.flavor_name
}

// Data sources for the networks (to get their IDs)
data "openstack_networking_network_v2" "networks" {
  count = length(var.network_names)
  name  = var.network_names[count.index]
}

// Create a compute instance
resource "openstack_compute_instance_v2" "multi_net_instance" {
  name              = var.instance_name
  image_id          = data.openstack_images_image_v2.instance_image.id
  flavor_id         = data.openstack_compute_flavor_v2.instance_flavor.id
  key_pair          = var.key_pair_name
  security_groups   = var.security_groups
  availability_zone = var.availability_zone

  dynamic "network" {
    for_each = data.openstack_networking_network_v2.networks
    content {
      uuid = network.value.id
      // port = openstack_networking_port_v2.port[network.key].id # For more control over ports
    }
  }

  // Optional: User data to run on instance startup
  // user_data = "#!/bin/bash\necho 'Hello from Terraform!' > /tmp/hello.txt"

  depends_on = [
    data.openstack_networking_network_v2.networks
  ]
}

// Optional: Allocate and associate a floating IP to the first network interface
resource "openstack_networking_floatingip_v2" "fip" {
  count = var.assign_floating_ip ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  count       = var.assign_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  instance_id = openstack_compute_instance_v2.multi_net_instance.id
  // By default, associates with the first available port.
  // For specific port attachment:
  // fixed_ip = openstack_compute_instance_v2.multi_net_instance.network[0].fixed_ip_v4
}