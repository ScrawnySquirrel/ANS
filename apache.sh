#!/bin/bash

# Arguments
UNAME=$1
UPASS=$2

# Set usage description
FILENAME=$(basename $0)
USAGE="Usage: ${FILENAME} <username> <password>"

# Check required arguments
[ -z $UNAME ] || [ -z $UPASS ] && { echo -e "Missing arguments\n${USAGE}"; exit; }

echo Setting up Apache

# Install Apache
dnf install httpd
systemctl enable httpd

# Enable user accounts
UDIR_PATH=/etc/httpd/conf.d/userdir.conf
UDIR_DISABLE="UserDir disable"
UDIR_HTML="UserDir public_html"
sed -i "/^$UDIR_DISABLE/ c#$UDIR_DISABLE" $UDIR_PATH
sed -i "/^#$UDIR_HTML/ c$UDIR_HTML" $UDIR_PATH

# Create user if not exist
if id -u $UNAME; then
  echo User found
else
  echo Creating user
  useradd $UNAME
fi

# Create public_html if not exist
UHOME=$(eval echo "~$UNAME")
if [[ ! -d $UHOME/public_html ]]; then
  if ! mkdir $UHOME/public_html; then
    echo "Can't create user's public_html" && exit 1
  fi
fi

# Set user home directory permissions
chmod 755 -R $UHOME

# Create user's index.html
echo "${UNAME}'s home page" > $UHOME/public_html/index.html

AUTH_FILE=$UNAME

# Allow user specific public_html
sed -i '/<Directory \"\/home\/\*\/public_html\">/,/<\/Directory>/d' $UDIR_PATH

# Set passwords config
if ! grep "<Directory /var/www/html/passwords>" $UDIR_PATH; then
  echo -e "<Directory /var/www/html/passwords>\n  order deny,allow\n  deny from all\n</Directory>\n" >> $UDIR_PATH
fi

# Append user configuration
if ! grep "<Directory /home/$UNAME>" $UDIR_PATH; then
  echo -e "<Directory /home/$UNAME>\n  AllowOverride None\n  AuthUserFile /var/www/html/passwords/$AUTH_FILE\n  AuthGroupFile /dev/null\n  AuthName test\n  AuthType Basic\n  <Limit GET>\n    require valid-user\n    order deny,allow\n    deny from all\n    allow from all\n  </Limit>\n</Directory>\n" >> $UDIR_PATH
fi

# Create password directory
PW_PATH=/var/www/html/passwords
[ ! -d $PW_PATH ] && { mkdir $PW_PATH; }
chmod 755 -R $PW_PATH
cd $PW_PATH
htpasswd -bc $AUTH_FILE $UNAME $UPASS

# Restart service
systemctl restart httpd
systemctl is-active --quiet httpd && echo httpd is running
setenforce 0

# Output access details
SVR_IP=$(hostname -I | awk '{print $1}')
[ $? -ne 0 ] && { SVR_IP="<hostname/IP>"; }
echo "Apache Access: http://${SVR_IP}/~${UNAME}/"

echo Apache finished
