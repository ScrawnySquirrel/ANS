#!/bin/bash

HELP="help me"

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

[ ! $APACHE ] && [ ! $NFS ] && [ ! $SAMBA ] && { echo "No tasks selected"; echo $HELP; exit; }

# Apache Setup
if [[ $APACHE ]]; then
  echo Setting up Apache
  [ -z $UNAME ] || [ -z $PASSWD ] && { echo "Apache: Missing arguments"; echo $HELP; break; }
  echo Apache finished
fi

# NFS Setup
if [[ $NFS ]]; then
  echo Setting up NFS
  [ -z $UNAME ] || [ -z $PASSWD ] || [ -z $MOUNT_PATH ] && { echo "NFS: Missing arguments"; echo $HELP; break; }
  echo NFS finished
fi

# Samba Setup
if [[ $SAMBA ]]; then
  echo Setting up Samba
  [ -z $UNAME ] || [ -z $PASSWD ] || [ -z $MOUNT_PATH ] && { echo "Samba: Missing arguments"; echo $HELP; break; }
  echo Samba finished
fi
