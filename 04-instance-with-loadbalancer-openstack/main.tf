// --- Network Data ---
data "openstack_networking_network_v2" "app_network" {
  name = var.network_name
}

data "openstack_networking_subnet_v2" "app_subnet" {
  name       = var.subnet_name
  network_id = data.openstack_networking_network_v2.app_network.id
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
  name        = var.instance_sg_name
  description = "Security group for web server instances behind LB"
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

// Allow HTTP from specified CIDR (e.g., from LB or public if testing directly)
resource "openstack_networking_secgroup_rule_v2" "instance_sg_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.lb_pool_member_port
  port_range_max    = var.lb_pool_member_port
  remote_ip_prefix  = var.http_allowed_cidr
  security_group_id = openstack_networking_secgroup_v2.instance_sg.id
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
  user_data         = file("${path.module}/scripts/user-data.sh")

  network {
    uuid = data.openstack_networking_network_v2.app_network.id
    // port = openstack_networking_port_v2.instance_port[count.index].id // For more control
  }

  depends_on = [openstack_networking_secgroup_v2.instance_sg]
}

// --- Load Balancer Resources (Octavia LBaaS v2) ---

// 1. Load Balancer
resource "openstack_lb_loadbalancer_v2" "web_lb" {
  name          = var.lb_name
  vip_subnet_id = data.openstack_networking_subnet_v2.app_subnet.id
  description   = "Load balancer for web application"
  tags          = ["environment:example", "terraform:true"]
}

// 2. Listener
resource "openstack_lb_listener_v2" "http_listener" {
  name            = "${var.lb_name}-http-listener"
  protocol        = "HTTP"
  protocol_port   = var.lb_listener_port
  loadbalancer_id = openstack_lb_loadbalancer_v2.web_lb.id
  description     = "HTTP listener for the web LB"
}

// 3. Pool
resource "openstack_lb_pool_v2" "http_pool" {
  name        = "${var.lb_name}-http-pool"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN" // Other options: LEAST_CONNECTIONS, SOURCE_IP
  listener_id = openstack_lb_listener_v2.http_listener.id // Link to the listener
  description = "Pool of web servers"
}

// 4. Health Monitor for the Pool
resource "openstack_lb_monitor_v2" "http_monitor" {
  name        = "${var.lb_name}-http-monitor"
  pool_id     = openstack_lb_pool_v2.http_pool.id
  type        = "HTTP" // Or TCP, HTTPS, PING
  delay       = 30     // Seconds
  timeout     = 10     // Seconds
  max_retries = 3
  // For HTTP/S monitors:
  // http_method = "GET"
  // url_path    = "/"
  // expected_codes = "200"
}

// 5. Pool Members (one for each instance)
resource "openstack_lb_member_v2" "app_member" {
  count         = var.instance_count
  name          = "${var.lb_name}-member-${count.index + 1}"
  pool_id       = openstack_lb_pool_v2.http_pool.id
  address       = openstack_compute_instance_v2.app_instance[count.index].access_ip_v4 // Use fixed IP
  protocol_port = var.lb_pool_member_port
  subnet_id     = data.openstack_networking_subnet_v2.app_subnet.id // Subnet of the instance's IP

  depends_on = [
    openstack_compute_instance_v2.app_instance,
    openstack_lb_monitor_v2.http_monitor // Ensure monitor is created before members are active
  ]
}

// --- Optional: Floating IP for Load Balancer ---
resource "openstack_networking_floatingip_v2" "lb_fip" {
  count = var.assign_lb_floating_ip ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "openstack_networking_floatingip_associate_v2" "lb_fip_associate" {
  count       = var.assign_lb_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.lb_fip[0].address
  port_id     = openstack_lb_loadbalancer_v2.web_lb.vip_port_id // Associate with the LB's VIP port
}