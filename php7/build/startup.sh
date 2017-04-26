!#/bin/bash

if [ ! -f /etc/apache2/sites-enabled/dw.conf ]; then
echo "Configure apache..."
cat << EOF > /etc/apache2/sites-enabled/dw.conf
<VirtualHost *:80>
DocumentRoot /var/www/html/dw/

<Directory /var/www/html/dw>
  Options Indexes FollowSymLinks MultiViews
  AllowOverride All
  Order allow,deny
  allow from all
</Directory>

ErrorLog /var/www/log/error.log
LogLevel warn
CustomLog /var/www/log/access.log combined
ServerSignature Off
</VirtualHost>
EOF
fi

/usr/sbin/apache2ctl -D FOREGROUND