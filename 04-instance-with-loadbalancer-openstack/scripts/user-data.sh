#!/bin/bash
# Update and install Apache
apt-get update -y
apt-get install -y apache2

# Start and enable Apache
systemctl start apache2
systemctl enable apache2

# Create a simple index.html page showing the hostname
echo "<h1>Hello World from $(hostname)</h1><p>This server is part of a load balanced pool managed by Terraform.</p>" > /var/www/html/index.html

# For Ubuntu 22.04 with cloud-init, ensure Apache starts after network is fully up
# (This might not be strictly necessary for all cloud images but is good practice)
# You might need to adjust if using a different OS or init system.