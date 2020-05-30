#!/bin/bash

FILENAME=$(basename $0)
HELP="Usage: \n${FILENAME} [-a] [-n] [-s] [-u username] [-p password] [-i destination_ip] [-m mount_path]\n -a\tSetup Apache\n -n\tSetup NFS\n -s\tSetup Samba\n -u\tUsername for login \n -p\tPassword for the login user\n -i\tDestination IP address\n -m\tMount path"

PARAMS=""

while (( "$#" )); do
  case "$1" in
    -a|--apache)
      APACHE=true
      shift
      ;;
    -n|--nfs)
      NFS=true
      shift
      ;;
    -s|--samba)
      SAMBA=true
      shift
      ;;
    -u|--user)
      UNAME=$2
      shift 2
      ;;
    -p|--pass)
      PASSWD=$2
      shift 2
      ;;
    -i|--ip)
      DEST_IP=$2
      shift 2
      ;;
    -m|--mount)
      MOUNT_PATH=$2
      shift 2
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"

[ ! $APACHE ] && [ ! $NFS ] && [ ! $SAMBA ] && { echo "No tasks selected"; echo -e $HELP; exit; }

APACHE_ERR=false
NFS_ERR=false
SAMBA_ERR=false

# Apache Setup
if [[ $APACHE ]]; then
  [ -z $UNAME ] || [ -z $PASSWD ] && { echo "Apache: Missing arguments"; APACHE_ERR=true; }
  [ ! $APACHE_ERR ] && { ./apache.sh $UNAME $PASSWD; }
fi

# NFS Setup
if [[ $NFS ]]; then
  [ -z $UNAME ] || [ -z $PASSWD ] || [ -z $MOUNT_PATH ] || [ -z $DEST_IP ] && { echo "NFS: Missing arguments"; NFS_ERR=true; }
  [ ! $NFS_ERR ] && { ./nfs.sh $UNAME $MOUNT_PATH $DEST_IP; }
fi

# Samba Setup
if [[ $SAMBA ]]; then
  [ -z $UNAME ] || [ -z $PASSWD ] || [ -z $MOUNT_PATH ] && { echo "Samba: Missing arguments"; SAMBA_ERR=true; }
  [ ! $SAMBA_ERR] && { ./samba.sh $UNAME $PASSWD $MOUNT_PATH; }
fi

[ APACHE_ERR ] || [ NFS_ERR ] || [ SAMBA_ERR ] && { echo -e $HELP; }
