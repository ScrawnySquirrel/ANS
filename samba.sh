#!/bin/bash

# Arguments
UNAME=$1
UPASS=$2
MPATH=$3

FILENAME=$(basename $0)
USAGE="Usage: ${FILENAME} <username> <password> <mount-path>"

[ -z $UNAME ] || [ -z $UPASS ] || [ -z $MPATH ] && { echo -e "Missing arguments\n${USAGE}"; exit; }

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
echo | smbclient -L localhost

SVR_IP=$(hostname -I | awk '{print $1}')
[ $? -ne SVR_IP ] && { SVR_IP="<hostname/IP>"; }
echo "Samba Mount: \\\\${SVR_IP}\\${UNAME}"

echo Samba finished
