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

# Create a volume
resource "openstack_blockstorage_volume_v3" "data_volume" {
  name              = var.volume_name
  size              = var.volume_size
  volume_type       = var.volume_type
  availability_zone = var.availability_zone
  
  metadata = {
    attached_to = var.instance_name
    created_by  = "terraform"
  }
}

# Create an OpenStack compute instance
resource "openstack_compute_instance_v2" "instance_with_volume" {
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
      has_volume = "true"
    },
    var.metadata
  )

  # We need to wait for the instance to be fully created before attaching the volume
  # Otherwise the volume setup script might not work correctly
}

# Attach the volume to the instance
resource "openstack_compute_volume_attach_v2" "attach_data_volume" {
  instance_id = openstack_compute_instance_v2.instance_with_volume.id
  volume_id   = openstack_blockstorage_volume_v3.data_volume.id
  device      = var.volume_device
  
  # This will wait until the instance is fully created and
  # the volume is attached before proceeding
}

# Create a floating IP
resource "openstack_networking_floatingip_v2" "instance_fip" {
  pool = var.floating_ip_pool
}

# Associate floating IP with the instance
resource "openstack_compute_floatingip_associate_v2" "instance_fip_association" {
  floating_ip = openstack_networking_floatingip_v2.instance_fip.address
  instance_id = openstack_compute_instance_v2.instance_with_volume.id

  # Wait until the volume is attached before associating the floating IP
  depends_on = [openstack_compute_volume_attach_v2.attach_data_volume]
}

# Setup the volume on the instance using remote-exec provisioner
# This will format and mount the volume
resource "null_resource" "setup_volume" {
  # This resource will be created after the instance has a floating IP
  depends_on = [
    openstack_compute_floatingip_associate_v2.instance_fip_association,
    openstack_compute_volume_attach_v2.attach_data_volume
  ]

  # Connection details for SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"  # Adjust according to your image's default user
    host        = openstack_networking_floatingip_v2.instance_fip.address
    private_key = file("~/.ssh/id_rsa")  # Path to your private SSH key
    timeout     = "2m"
  }
  
  # Copy the setup script
  provisioner "file" {
    source      = "${path.module}/scripts/setup_volume.sh"
    destination = "/tmp/setup_volume.sh"
  }
  
  # Execute the setup script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_volume.sh",
      "sudo /tmp/setup_volume.sh ${var.volume_device} ${var.volume_mount_point} ${var.volume_filesystem}"
    ]
  }
}