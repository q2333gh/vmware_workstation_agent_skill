#!/bin/bash
# VMware Shared Folders Auto-Mount Setup Script for Ubuntu
# This script sets up automatic mounting of VMware shared folders on boot
# Based on best practices for modern Ubuntu with open-vm-tools

MOUNT_POINT="/mnt/hgfs"
MOUNT_ALL_SHARES=true  # Set to false to mount specific share only
SHARE_NAME="share_folder1"  # Only used if MOUNT_ALL_SHARES=false

echo "=== VMware Shared Folders Auto-Mount Setup ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Detect user ID and group ID
USER_ID=$(id -u)
GROUP_ID=$(id -g)
echo "Detected user ID: $USER_ID, group ID: $GROUP_ID"
echo ""

# Check if open-vm-tools or VMware Tools is installed
if command -v vmhgfs-fuse &> /dev/null; then
    echo "✓ Found vmhgfs-fuse (open-vm-tools)"
    USE_FUSE=true
elif command -v mount.vmhgfs &> /dev/null; then
    echo "✓ Found mount.vmhgfs (traditional VMware Tools)"
    USE_FUSE=false
else
    echo "✗ Error: Neither vmhgfs-fuse nor mount.vmhgfs found."
    echo "Please install open-vm-tools: sudo apt-get install open-vm-tools"
    exit 1
fi

# Create mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point: $MOUNT_POINT"
    mkdir -p "$MOUNT_POINT"
    chmod 755 "$MOUNT_POINT"
else
    echo "Mount point already exists: $MOUNT_POINT"
fi

# Check if already in fstab
if grep -q "$MOUNT_POINT" /etc/fstab; then
    echo "Warning: Entry already exists in /etc/fstab"
    echo "Current entry:"
    grep "$MOUNT_POINT" /etc/fstab
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    # Remove old entries
    sed -i "\|$MOUNT_POINT|d" /etc/fstab
fi

# Add entry to /etc/fstab
echo "Adding entry to /etc/fstab..."

if [ "$USE_FUSE" = true ]; then
    # Modern method: fuse.vmhgfs-fuse (recommended for Ubuntu 16.04+)
    if [ "$MOUNT_ALL_SHARES" = true ]; then
        # Mount all shared folders (recommended approach)
        # nofail: prevents boot hang if shared folder is unavailable
        FSTAB_ENTRY=".host:/ $MOUNT_POINT fuse.vmhgfs-fuse uid=$USER_ID,gid=$GROUP_ID,defaults,nofail 0 0"
    else
        # Mount specific share (handle spaces in share name)
        # nofail: prevents boot hang if shared folder is unavailable
        FSTAB_ENTRY=".host:/\"$SHARE_NAME\" $MOUNT_POINT/\"$SHARE_NAME\" fuse.vmhgfs-fuse allow_other,default_permissions,uid=$USER_ID,nofail 0 0"
        mkdir -p "$MOUNT_POINT/$SHARE_NAME"
    fi
else
    # Legacy method: vmhgfs (for older VMware Tools)
    if [ "$MOUNT_ALL_SHARES" = true ]; then
        # nofail: prevents boot hang if shared folder is unavailable
        FSTAB_ENTRY=".host:/ $MOUNT_POINT vmhgfs defaults,ttl=5,uid=$USER_ID,gid=$GROUP_ID,umask=022,nofail 0 0"
    else
        # nofail: prevents boot hang if shared folder is unavailable
        FSTAB_ENTRY=".host:/$SHARE_NAME $MOUNT_POINT/$SHARE_NAME vmhgfs defaults,ttl=5,uid=$USER_ID,gid=$GROUP_ID,umask=022,nofail 0 0"
        mkdir -p "$MOUNT_POINT/$SHARE_NAME"
    fi
fi

echo "$FSTAB_ENTRY" >> /etc/fstab

echo ""
echo "Entry added to /etc/fstab:"
echo "$FSTAB_ENTRY"
echo ""

# Test mount
echo "Testing mount..."
if mount "$MOUNT_POINT" 2>/dev/null || mount -a 2>/dev/null; then
    echo "✓ Mount successful!"
    echo ""
    echo "Contents of $MOUNT_POINT:"
    ls -la "$MOUNT_POINT" 2>/dev/null || echo "(Directory may be empty or permissions issue)"
    echo ""
    
    # List available shares
    if command -v vmware-hgfsclient &> /dev/null; then
        echo "Available shared folders:"
        vmware-hgfsclient
        echo ""
    fi
    
    echo "✓ Setup completed successfully!"
    echo "The shared folder(s) will be automatically mounted on boot."
else
    echo "✗ Mount test failed. This might be normal if VM is not fully booted."
    echo "The entry has been added to /etc/fstab and will mount on next boot."
    echo ""
    echo "To test manually after VM is fully booted, run:"
    echo "  sudo mount $MOUNT_POINT"
fi
