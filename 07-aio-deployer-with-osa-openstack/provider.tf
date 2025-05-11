# Configure the OpenStack Provider
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
  required_version = ">= 1.5.0"
}

# Define OpenStack Provider
provider "openstack" {
  # OpenStack authentication is typically provided via environment variables
  # OS_AUTH_URL, OS_TENANT_NAME, OS_USERNAME, OS_PASSWORD, etc.
  # You can also define them here if preferred
  # auth_url    = var.os_auth_url
  # tenant_name = var.os_tenant_name
  # user_name   = var.os_username
  # password    = var.os_password
  # region      = var.os_region
}