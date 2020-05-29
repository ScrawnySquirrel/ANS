#!/bin/bash

# Arguments
UNAME=$1
UPASS=$2
MPATH=$3
DEST_IP=$4

[ -z $UNAME ] || [ -z $UPASS ] || [ -z $MPATH ] || [ -z $DEST_IP ] && { echo "Missing arguments"; exit; }

echo Setting up NFS

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

echo NFS finished
