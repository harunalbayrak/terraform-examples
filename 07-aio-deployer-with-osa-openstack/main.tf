data "openstack_networking_network_v2" "aio_net" {
  name = var.aio_network_name
}

data "openstack_images_image_v2" "aio_image" {
  name        = var.aio_image_name
  most_recent = true
}

data "openstack_compute_flavor_v2" "aio_flavor" {
  name = var.aio_flavor_name
}

data "openstack_networking_network_v2" "external_net" {
  name = var.aio_external_network_name
}

resource "openstack_networking_secgroup_v2" "aio_sg" {
  name        = "${var.aio_instance_name}-sg"
  description = "Security group for OSA AIO instance ${var.aio_instance_name}"
  tags        = var.aio_tags
}

resource "openstack_networking_secgroup_rule_v2" "aio_sg_tcp_ports" {
  for_each          = toset(var.aio_security_group_ports)
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value
  port_range_max    = each.value
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.aio_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "aio_sg_icmp" {
  description       = "Allow ICMP (ping)"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.aio_sg.id
}

resource "openstack_compute_instance_v2" "aio_server" {
  name              = var.aio_instance_name
  image_id          = data.openstack_images_image_v2.aio_image.id
  flavor_id         = data.openstack_compute_flavor_v2.aio_flavor.id
  key_pair          = var.aio_key_pair_name
  security_groups   = [openstack_networking_secgroup_v2.aio_sg.name]
  availability_zone = var.aio_availability_zone
  tags              = var.aio_tags
  config_drive      = true # Essential for cloud-init user_data

  network {
    uuid = data.openstack_networking_network_v2.aio_net.id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.aio_image.id
    source_type           = "image"
    destination_type      = "local" # Or "volume" if booting from a volume based on the image
    boot_index            = 0
    delete_on_termination = true
    volume_size           = var.aio_root_disk_size_gb # Check if your cloud provider & image support root disk resizing
  }

  user_data = templatefile("${path.module}/scripts/install_osa_aio.sh.tpl", {
    USER_PASSWORD                         = var.aio_instance_password
    DEFAULT_USER                          = var.aio_default_user
    OSA_BRANCH                            = var.osa_branch
    OSA_ENVIRONMENT_LAYOUT                = var.osa_environment_layout
    OSA_SCENARIO                          = var.osa_scenario
    OSA_INFRA_PROVIDER                    = var.osa_infra_provider
    OSA_ENABLE_HEAT                       = var.osa_enable_heat
    OSA_ENABLE_CINDER                     = var.osa_enable_cinder
    OSA_ENABLE_NEUTRON                    = var.osa_enable_neutron
    OSA_ENABLE_SWIFT                      = var.osa_enable_swift
    OSA_ENABLE_HORIZON                    = var.osa_enable_horizon
    OSA_BOOTSTRAP_ANSIBLE_PIP_PACKAGES_STR = join(" ", var.osa_bootstrap_ansible_pip_packages)
  })

  # Note: The OSA installation happens via user_data (cloud-init) script.
  # Terraform will complete once the instance is created and cloud-init starts.
  # The actual OSA deployment will run in the background on the instance.
}

resource "openstack_networking_floatingip_v2" "aio_fip" {
  pool = data.openstack_networking_network_v2.external_net.name
}

resource "openstack_networking_floatingip_associate_v2" "aio_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.aio_fip.address
  instance_id = openstack_compute_instance_v2.aio_server.id
  # fixed_ip can be specified if the instance has multiple NICs and you want to target a specific one.
  # fixed_ip    = openstack_compute_instance_v2.aio_server.network[0].fixed_ip_v4
}