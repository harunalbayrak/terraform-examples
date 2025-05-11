#!/bin/bash

# This script formats and mounts a volume on the instance
# It takes three parameters:
# $1: Device path
# $2: Mount point
# $3: Filesystem type

# Exit on any error
set -e

# Check if we received all required parameters
if [ $# -lt 3 ]; then
    echo "Error: Missing parameters"
    echo "Usage: $0 <device_path> <mount_point> <filesystem>"
    exit 1
fi

DEVICE=$1
MOUNT_POINT=$2
FILESYSTEM=$3

echo "$(date) - Starting volume setup script" > /var/log/volume_setup.log
echo "Device: $DEVICE" >> /var/log/volume_setup.log
echo "Mount point: $MOUNT_POINT" >> /var/log/volume_setup.log
echo "Filesystem: $FILESYSTEM" >> /var/log/volume_setup.log

# Wait for the device to be available
echo "$(date) - Waiting for device $DEVICE to be available..." >> /var/log/volume_setup.log
for i in {1..10}; do
    if [ -e $DEVICE ]; then
        echo "$(date) - Device $DEVICE is now available" >> /var/log/volume_setup.log
        break
    fi
    echo "$(date) - Attempt $i: Device not available yet, waiting..." >> /var/log/volume_setup.log
    sleep 5
done

# Check if device exists after waiting
if [ ! -e $DEVICE ]; then
    echo "$(date) - Error: Device $DEVICE not available after waiting" >> /var/log/volume_setup.log
    exit 1
fi

# Check if device is already formatted
echo "$(date) - Checking if device is already formatted" >> /var/log/volume_setup.log
if ! blkid $DEVICE &> /dev/null; then
    # Format the volume if it's not already formatted
    echo "$(date) - Formatting device $DEVICE with $FILESYSTEM" >> /var/log/volume_setup.log
    mkfs -t $FILESYSTEM $DEVICE
    if [ $? -ne 0 ]; then
        echo "$(date) - Error: Failed to format device $DEVICE" >> /var/log/volume_setup.log
        exit 1
    fi
else
    echo "$(date) - Device $DEVICE is already formatted" >> /var/log/volume_setup.log
fi

# Create mount point if it doesn't exist
echo "$(date) - Creating mount point $MOUNT_POINT" >> /var/log/volume_setup.log
mkdir -p $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "$(date) - Error: Failed to create mount point $MOUNT_POINT" >> /var/log/volume_setup.log
    exit 1
fi

# Get UUID of the device
UUID=$(blkid -s UUID -o value $DEVICE)
if [ -z "$UUID" ]; then
    echo "$(date) - Error: Could not get UUID for device $DEVICE" >> /var/log/volume_setup.log
    exit 1
fi
echo "$(date) - Device UUID: $UUID" >> /var/log/volume_setup.log

# Check if mount point is already in fstab
if grep -q "$MOUNT_POINT" /etc/fstab; then
    echo "$(date) - Mount point $MOUNT_POINT already exists in fstab. Updating..." >> /var/log/volume_setup.log
    # Remove existing entry
    sed -i "\|$MOUNT_POINT|d" /etc/fstab
fi

# Add to fstab for persistent mounting
echo "$(date) - Adding entry to /etc/fstab" >> /var/log/volume_setup.log
echo "UUID=$UUID $MOUNT_POINT $FILESYSTEM defaults,nofail 0 2" >> /etc/fstab

# Mount the volume
echo "$(date) - Mounting device $DEVICE to $MOUNT_POINT" >> /var/log/volume_setup.log
mount $MOUNT_POINT
if [ $? -ne 0 ]; then
    echo "$(date) - Error: Failed to mount $DEVICE to $MOUNT_POINT" >> /var/log/volume_setup.log
    exit 1
fi

# Set appropriate permissions
echo "$(date) - Setting permissions on $MOUNT_POINT" >> /var/log/volume_setup.log
chown ubuntu:ubuntu $MOUNT_POINT
chmod 755 $MOUNT_POINT

# Create a test file
echo "$(date) - Creating test file on volume" >> /var/log/volume_setup.log
echo "Volume successfully mounted on $(date)" > $MOUNT_POINT/volume_info.txt
chown ubuntu:ubuntu $MOUNT_POINT/volume_info.txt

echo "$(date) - Volume setup completed successfully" >> /var/log/volume_setup.log
echo "Volume setup completed successfully" > $MOUNT_POINT/setup_completed

exit 0