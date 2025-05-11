#!/bin/bash

# Log startup script execution
echo "$(date) - Starting instance initialization script" >> /var/log/startup.log

# Update system packages
echo "$(date) - Updating system packages" >> /var/log/startup.log
apt-get update
apt-get upgrade -y

# Install common tools
echo "$(date) - Installing common tools" >> /var/log/startup.log
apt-get install -y \
    curl \
    wget \
    vim \
    git \
    htop \
    net-tools \
    nginx

# Configure basic nginx server
echo "$(date) - Configuring nginx" >> /var/log/startup.log
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>OpenStack Terraform Instance</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            line-height: 1.6;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        h1 {
            color: #333;
        }
        .info {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Instance Successfully Deployed</h1>
        <div class="info">
            <p>This instance was created by Terraform on $(date).</p>
            <p>Hostname: $(hostname)</p>
            <p>IP Address: $(hostname -I | awk '{print $1}')</p>
        </div>
        <p>The startup script has completed successfully.</p>
    </div>
</body>
</html>
EOF

# Start nginx service
systemctl enable nginx
systemctl restart nginx

# Setup basic firewall
echo "$(date) - Setting up firewall" >> /var/log/startup.log
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "y" | ufw enable

# Create a status file to indicate completion
echo "$(date) - Startup script completed" > /var/lib/cloud/instance/startup-script-completed

echo "$(date) - Instance initialization completed" >> /var/log/startup.log
