#!/bin/bash

# Arguments
UNAME=$1
DEST_IP=$2
MPATH=$3

FILENAME=$(basename $0)
USAGE="Usage: ${FILENAME} <username> <destination-ip> <mount-path>"

[ -z $UNAME ] || [ -z $MPATH ] || [ -z $DEST_IP ] && { echo -e "Missing arguments\n${USAGE}"; exit; }

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

UHOME=$(eval echo "~$UNAME")
chmod 755 -R $UHOME

# Setup exports
EXPORTS=/etc/exports
echo "$MPATH ${DEST_IP}(rw,insecure,no_root_squash)" >>  $EXPORTS

# Start NFS
systemctl restart nfs-server
exportfs -v

SVR_IP=$(hostname -I | awk '{print $1}')
[ $? -ne SVR_IP] && { SVR_IP="<hostname/IP>"}
echo "NFS Mount: mkdir ${UNAME}; mount -t nfs ${SVR_IP}:/${UHOME} ${UNAME}"

echo NFS finished
