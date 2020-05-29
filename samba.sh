#!/bin/bash

# Arguments
UNAME=$1
UPASS=$2
MPATH=$3

[ -z $UNAME ] || [ -z $UPASS ] || [ -z $MPATH ] && { echo "Missing arguments"; exit; }

echo Setting up Samba

dnf install samba
systemctl enable smb.service

# Create user if not exist
if id -u $UNAME; then
  echo User found
else
  echo Creating user
  useradd $UNAME
fi

# Setup configuration
SMB_CONF=/etc/samba/smb.conf
echo -e "[${UNAME}]\n\tpath = ${MPATH}\n\tpublic = yes\n\twritable = yes\n\tguest ok = yes\n\tprintable = no\n" >> $SMB_CONF

# Set authentication
(echo $UPASS; echo $UPASS) | smbpasswd -s -a $UNAME

# Start Samba
systemctl restart smb
smbclient -L localhost

echo Samba finished
