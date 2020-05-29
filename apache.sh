#!/bin/bash

# Arguments
UNAME=$1
UPASS=$2

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

AUTH_FILE=$UNAME

# Comment out
sed -i '/<Directory \"\/home\/\*\/public_html\">/,/<\/Directory>/d' $UDIR_PATH
# <Directory "/home/*/public_html">
#   AllowOverride FileInfo AuthConfig Limit Indexes
#   Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
#   Require method GET POST OPTIONS
# </Directory>

# Append if not already
if ! grep "<Directory /var/www/html/passwords>" $UDIR_PATH; then
  echo -n "<Directory /var/www/html/passwords>\n  order deny,allow\n  deny from all\n</Directory>\n" >> $UDIR_PATH
fi

# Append for user
if ! grep "<Directory /home/$UNAME>" $UDIR_PATH; then
  echo -n "<Directory /home/$UNAME>\n  AllowOverride None\n  AuthUserFile /var/www/html/passwords/$AUTH_FILE\n  AuthGroupFile /dev/null\n  AuthName test\n  AuthType Basic\n  <Limit GET>\n    require valid-user\n    order deny,allow\n    deny from all\n    allow from all\n  </Limit>\n</Directory>\n" >> $UDIR_PATH
fi

# Create password directory
mkdir /var/www/html/passwords; chmod 755 /var/www/html/passwords; cd /var/www/html/passwords
htpasswd -c $AUTH_FILE $UNAME
