#!/bin/bash

# Arguments
UNAME=$1
UPASS=$2
MPATH=$3
DEST_IP=$4

# Install NFS
dnf install nfs-utils
systemctl enable nfs-server.service

# Create user if not exist
if id -u $UNAME; then
  echo User found
else
  echo Creating user
  useradd $UNAME
fi

# Setup exports
EXPORTS=/etc/exports
echo "$MPATH ${DEST_IP}(rw,insecure,no_root_squash)" >>  $EXPORTS

# Start NFS
systemctl restart nfs-server
exportfs -v
