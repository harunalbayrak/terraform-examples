#!/bin/bash
# OpenStack-Ansible (OSA) All-In-One (AIO) Installation Script for cloud-init
# This script will be executed by cloud-init on the first boot.
# All output is redirected to a log file for debugging.
exec > /var/log/cloud-init-osa-deploy.log 2>&1

set -euxo pipefail # Exit on error, unset variables, and pipe failures

echo "INFO: Starting OSA AIO Deployment Script at $(date)"

# --- Script Parameters (Injected by Terraform templatefile function) ---
USER_PASSWORD="${USER_PASSWORD}"
DEFAULT_USER="${DEFAULT_USER}"
OSA_BRANCH="${OSA_BRANCH}"
OSA_ENVIRONMENT_LAYOUT="${OSA_ENVIRONMENT_LAYOUT}" # e.g., "aio"
OSA_SCENARIO="${OSA_SCENARIO}"                   # e.g., "base", "network_lvm"
OSA_INFRA_PROVIDER="${OSA_INFRA_PROVIDER}"             # e.g., "lxc", "metal"
OSA_ENABLE_HEAT="${OSA_ENABLE_HEAT}"
OSA_ENABLE_CINDER="${OSA_ENABLE_CINDER}"
OSA_ENABLE_NEUTRON="${OSA_ENABLE_NEUTRON}"
OSA_ENABLE_SWIFT="${OSA_ENABLE_SWIFT}"
OSA_ENABLE_HORIZON="${OSA_ENABLE_HORIZON}"
OSA_BOOTSTRAP_ANSIBLE_PIP_PACKAGES_STR="${OSA_BOOTSTRAP_ANSIBLE_PIP_PACKAGES_STR}"

# --- System Preparation ---
echo "INFO: Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
# Essential packages for OSA and general utilities
apt-get install -y git curl python3-pip python3-venv crudini bridge-utils ebtables socat ntp software-properties-common

# For newer OSA, Ansible PPA might be needed if distro version is too old
# add-apt-repository --yes --update ppa:ansible/ansible
# apt-get install -y ansible # Or let bootstrap-ansible handle it

echo "INFO: Configuring and starting NTP service..."
systemctl enable ntp || systemctl enable ntpd # systemd service name can vary
systemctl start ntp || systemctl start ntpd
timedatectl set-ntp true

# Enable Password Authentication for SSH (if USER_PASSWORD is set)
# WARNING: This is a security risk. Use key-based authentication whenever possible.
if [ -n "$USER_PASSWORD" ] && [ "$USER_PASSWORD" != "null" ]; then # Check for "null" string from Terraform
    echo "INFO: Enabling password authentication and setting password for user '$DEFAULT_USER'."
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    echo "$DEFAULT_USER:$USER_PASSWORD" | chpasswd
    systemctl restart sshd || systemctl restart ssh
else
    echo "INFO: Password for SSH not set or disabled. Key-based authentication is expected."
fi

# Set hostname (OSA might rely on this being resolvable)
# The instance name from Terraform is usually set as hostname by cloud-init
# Ensure localhost resolves correctly
if ! grep -q "127.0.0.1 $(hostname)" /etc/hosts; then
    echo "INFO: Adding $(hostname) to /etc/hosts for 127.0.0.1"
    echo "127.0.0.1 $(hostname)" >> /etc/hosts
fi

# --- Clone OpenStack-Ansible ---
OSA_DIR="/opt/openstack-ansible"
echo "INFO: Cloning OpenStack-Ansible branch '${OSA_BRANCH}' into ${OSA_DIR}..."
if [ -d "${OSA_DIR}" ]; then
    echo "INFO: Removing existing ${OSA_DIR} directory..."
    rm -rf "${OSA_DIR}"
fi
git clone https://opendev.org/openstack/openstack-ansible "${OSA_DIR}" -b "${OSA_BRANCH}"
cd "${OSA_DIR}"

# --- Bootstrap Ansible ---
# This script prepares the system and installs Ansible in a virtual environment.
echo "INFO: Bootstrapping Ansible environment..."
# Pass additional pip packages if any
if [ -n "$OSA_BOOTSTRAP_ANSIBLE_PIP_PACKAGES_STR" ]; then
    export BOOTSTRAP_OPTS="pip_install_options='${OSA_BOOTSTRAP_ANSIBLE_PIP_PACKAGES_STR}'"
fi
scripts/bootstrap-ansible.sh

# Activate the Ansible virtual environment created by bootstrap-ansible.sh
# The path to the activate script might vary slightly or a wrapper is created.
# Common path for the wrapper/activator:
OSA_WRAPPER_SCRIPT="/usr/local/bin/openstack-ansible"
OSA_VENV_ACTIVATE_SCRIPT="/usr/local/bin/openstack-ansible-activate" # Or similar

if [ -f "$OSA_VENV_ACTIVATE_SCRIPT" ]; then
    echo "INFO: Sourcing Ansible venv from $OSA_VENV_ACTIVATE_SCRIPT"
    # shellcheck source=/dev/null
    source "$OSA_VENV_ACTIVATE_SCRIPT"
elif ! command -v openstack-ansible &> /dev/null; then
    echo "ERROR: openstack-ansible command not found after bootstrap. Trying to add /usr/local/bin to PATH."
    export PATH=$PATH:/usr/local/bin
    if ! command -v openstack-ansible &> /dev/null; then
        echo "ERROR: openstack-ansible still not found. OSA deployment cannot proceed."
        exit 1
    fi
fi
echo "INFO: Ansible (openstack-ansible command) should now be available."

# --- Prepare OSA Configuration ---
echo "INFO: Preparing OSA configuration files..."
# Copy default configuration
if [ -d "/etc/openstack_deploy" ]; then
    echo "INFO: Backing up existing /etc/openstack_deploy to /etc/openstack_deploy.bak"
    mv /etc/openstack_deploy /etc/openstack_deploy.bak."$(date +%s)"
fi
cp -r "${OSA_DIR}/etc/openstack_deploy" /etc/openstack_deploy

# Configure OSA for AIO
# AIO typically uses localhost for most services.
# The main AIO configuration is often in /etc/openstack_deploy/conf.d/aio.yml or similar.
# We will override specific service toggles via user_variables.yml

echo "INFO: Creating/Updating /etc/openstack_deploy/openstack_user_config.yml for AIO specifics..."
# For AIO, you typically define the layout and provider IPs (which is localhost for AIO)
# The IP address of the host itself.
# HOST_MAIN_IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}') # Assuming eth0 is the main interface
# For AIO, we mostly rely on 127.0.0.1 being correctly configured by OSA's AIO setup.
# Minimal openstack_user_config.yml, as AIO defaults handle much of this.
# If you need to override specific IPs, do it here.
cat << EOF > /etc/openstack_deploy/openstack_user_config.yml
---
# This file is intentionally kept minimal for AIO.
# OSA's AIO defaults will configure most services for localhost.
# Specific overrides can be placed here if needed.

# Example: If your AIO VM has a specific IP you want OSA to bind to for external access
# global_overrides:
#   internal_lb_vip_address: 127.0.0.1 # Default for AIO
#   external_lb_vip_address: 127.0.0.1 # Default for AIO
#   # If using a specific IP of the VM for external access:
#   # external_lb_vip_address: ${HOST_MAIN_IP}

# Specify environment layout, scenario, and infrastructure provider
# These are high-level settings that influence which OSA roles and playbooks are used.
environment_layout: "${OSA_ENVIRONMENT_LAYOUT}"
scenario: "${OSA_SCENARIO}"
infra_provider: "${OSA_INFRA_PROVIDER}"
EOF


echo "INFO: Creating /etc/openstack_deploy/user_variables.yml for service toggles and custom settings..."
cat << EOF > /etc/openstack_deploy/user_variables.yml
---
# Generated by Terraform cloud-init script for OSA AIO deployment

# Service Enablement (lowercase 'true'/'false' for YAML booleans)
cinder_enabled: ${OSA_ENABLE_CINDER,,}
heat_enabled: ${OSA_ENABLE_HEAT,,}
neutron_enabled: ${OSA_ENABLE_NEUTRON,,}
swift_enabled: ${OSA_ENABLE_SWIFT,,}
horizon_enabled: ${OSA_ENABLE_HORIZON,,}

# Example: If using Swift with loopback devices for AIO (testing only)
# Ensure swift_enabled is true above.
# swift_storage_disk_size: "5G" # Size for each loopback device
# swift_devices:
#   - { name: "loop0", path: "/srv/loop0.img", group: "default" } # These devices are created under /srv/node
#   - { name: "loop1", path: "/srv/loop1.img", group: "default" }
# You would need to create these loopback files/devices before running swift playbooks,
# or ensure OSA's swift role for AIO handles it.
# For simplicity, keeping Swift disabled by default is easier.

# Add any other custom user variables here.
# For example, to change default passwords (though secrets management is better):
# keystone_auth_admin_password: "yourStrongOpenStackAdminPassword"
EOF

# --- Run OSA Installation Playbooks ---
cd "${OSA_DIR}/playbooks"
echo "INFO: Starting OpenStack-Ansible playbook execution. This will take a long time..."

# Generate inventory and config before running playbooks
echo "INFO: Running setup-hosts.yml to prepare hosts and generate inventory..."
openstack-ansible setup-hosts.yml --forks 1 # Forks 1 is usually safer for AIO

echo "INFO: Running setup-infrastructure.yml to deploy infrastructure services (Galera, RabbitMQ, Memcached)..."
openstack-ansible setup-infrastructure.yml --forks 1

echo "INFO: Running setup-openstack.yml to deploy OpenStack services..."
openstack-ansible setup-openstack.yml --forks 1

# Alternatively, some OSA versions/AIO setups might use a wrapper script like:
# scripts/run-playbooks.sh # This script typically runs the sequence above.
# Check OSA documentation for the recommended AIO deployment method for your chosen branch.

echo "INFO: OpenStack-Ansible AIO deployment script finished execution at $(date)."
echo "INFO: Check /var/log/cloud-init-osa-deploy.log for full details."
echo "INFO: If successful, Horizon dashboard might be available at http://<FLOATING_IP>/horizon"
echo "INFO: Access the deployed OpenStack CLI by SSHing into the AIO VM and sourcing:"
echo "INFO: source /etc/openstack_deploy/admin-openrc.sh"
echo "INFO: --- OSA DEPLOYMENT SCRIPT END ---"