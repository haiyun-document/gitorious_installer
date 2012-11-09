#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## Make sure script is run as root
if [ "$(id -u)" != "0" ]; then
	echo "Script must be run as root!"
	exit 1
fi

## Check version of Ubuntu
UBUNTU_VERSION=`lsb_release -s -d`

if ! echo ${UBUNTU_VERSION} | grep --quiet "Ubuntu 12.04" ; then
	echo 	This script is designed to work with Ubuntu 12.04 LTS. You \
			are running "${UBUNTU_VERSION}".
	read -p "Override? [y/N] " OVERRIDE
	OVERRIDE=`echo "${OVERRIDE}" | tr '[A-Z]' '[a-z]'`
	
	if [ "${OVERRIDE}" != "y" ]; then
		echo "Quitting!"
		exit 2
	else
		echo "Overriding..."
	fi
fi

## This section will check necessary dependecies
DEPS=(build-essential  zlib1g-dev tcl-dev libexpat1-dev libxslt1-dev 	\
		libcurl4-openssl-dev postfix apache2 mysql-server mysql-client 	\
		apg geoip-bin libgeoip1 libgeoip-dev sqlite3 libsqlite3-dev 	\
		imagemagick libpcre3 libpcre3-dev zlib1g zlib1g-dev libyaml-dev \
		libmysqlclient-dev apache2-threaded-dev libonig-dev ruby-dev rubygems 	\
		libruby libdbd-mysql-ruby libmysql-ruby 				\
		libmagick++-dev zip unzip memcached git-core git-svn git-doc 	\
		git-cvs ruby wget)
		
MISSING_DEPS=()	
for DEP in "${DEPS[@]}"; do
	if  ! dpkg --get-selections | grep --quiet $DEP 
	then
		MISSING_DEPS+=("$DEP")
	fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]
then
	echo "You are missing: ${MISSING_DEPS[@]} "
	read -p "Install missing packages? [Y/n] " INSTALL_MISSING_PKGS
	INSTALL_MISSING_PKGS=`echo "${INSTALL_MISSING_PKGS}" | tr '[A-Z]' '[a-z]'`
	
	if [ "${INSTALL_MISSING_PKGS}" = "y" ] || [ -z "${INSTALL_MISSING_PKGS}" ]; then
		apt-get install -y "${MISSING_DEPS[@]}"
	fi
fi

## Install the Ruby Gems
REALLY_GEM_UPDATE_SYSTEM=1 gem update --system

gem install --no-ri --no-rdoc -v 0.8.7 rake
gem install --no-ri --no-rdoc -v 1.1.0 daemons
gem install -b --no-ri --no-rdoc rmagick stompserver passenger bundler

## Compile and install sphinx
cd /tmp
wget http://sphinxsearch.com/files/sphinx-0.9.9.tar.gz
tar -xzf sphinx-0.9.9.tar.gz
cd sphinx-0.9.9
./configure --prefix=/usr
make all install

## Clone Gitorious
git clone git://gitorious.org/gitorious/mainline.git /var/www/gitorious
cd /var/www/gitorious
git submodule init
git submodule update
ln -s /var/www/gitorious/script/gitorious /usr/bin

## Startup scripts
cp scripts/{git-{daemon,poller,ultrasphinx},stomp} /etc/init.d/
chmod 755 /etc/init.d/{git-{daemon,poller,ultrasphinx},stomp}

update-rc.d git-daemon defaults
update-rc.d git-poller defaults
update-rc.d git-ultrasphinx defaults
update-rc.d stomp defaults

## Make directories
function make_dir {
	mkdir -vp $1
}

DIRS=(/var/www/gitorious/tmp/pids /tmp/tarball-work /var/www/gitorious/tarballs
		/var/www/gitorious/repositories /var/www/gitorious/.ssh)
		
for DIR in ${DIRS[@]}; do
	make_dir ${DIR}
done

touch /var/www/gitorious/.ssh/authorized_keys 
chmod 700 /var/www/gitorious/.ssh
chmod 600 /var/www/gitorious/.ssh/authorized_keys


## Compile and load passenger for Apache
#$(gem contents passenger | grep passenger-install-apache2-module)
MOD_PASSENGER_LOC=`find /usr/lib/ruby/gems -name mod_passenger.so`
PASSENGER_DIR=`find /usr/lib/ruby/gems -type d -name passenger-*`
cat <<EOF > /etc/apache2/mods-available/passenger.load
LoadModule passenger_module ${MOD_PASSENGER_LOC}
   PassengerRoot ${PASSENGER_DIR}
   PassengerRuby /usr/bin/ruby1.8
EOF

cat /etc/apache2/mods-available/passenger.load
service apache2 reload

## Add modules
a2enmod passenger
a2enmod rewrite
a2enmod ssl

## Write Apache configuration files
read -p "Enter server name [git.example.com]: " SERVER_NAME

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

## Enable gitorious sites
a2ensite gitorious
a2ensite gitorious-ssl

service apache2 reload

## Get MySQL root password
read -s -p "Enter mysql root password: " MYSQL_PASSWD
echo \n

## Create gitorious_production database
mysql -u root -p"${MYSQL_PASSWD}" -e "CREATE DATABASE gitorious_production"

