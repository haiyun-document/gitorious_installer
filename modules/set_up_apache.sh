#!/bin/bash
service apache2 reload

## Add modules
a2enmod passenger
a2enmod rewrite
a2enmod ssl

## Write Apache configuration files
read -p "Input your server name [ex. git.example.com]: " SERVER_NAME

cat <<EOF > /etc/apache2/sites-available/gitorious
<VirtualHost *:80>
	ServerName $SERVER_NAME
	DocumentRoot /var/www/gitorious/public
</VirtualHost>
EOF

cat <<EOF > /etc/apache2/sites-available/gitorious-ssl 
<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		DocumentRoot /var/www/gitorious/public
		SSLEngine on
		SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
		SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
		BrowserMatch ".*MSIE.*" nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
	</VirtualHost>
</IfModule>
EOF

## Disable default site
a2dissite default
a2dissite default-ssl

## Enable gitorious site
a2ensite gitorious
a2ensite gitorious-ssl

