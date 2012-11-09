#!/bin/bash

## Make sure script is run as root
if [ "$(id -u)" != "0" ]; then
	echo "Script must be run as root!"
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

## This section will check necessary 
DEPS=(build-essential  zlib1g-dev tcl-dev libexpat-dev libxslt1-dev 	\
		libcurl4-openssl-dev postfix apache2 mysql-server mysql-client 	\
		apg geoip-bin libgeoip1 libgeoip-dev sqlite3 libsqlite3-dev 	\
		imagemagick libpcre3 libpcre3-dev zlib1g zlib1g-dev libyaml-dev \
		libmysqlclient15-dev apache2-dev libonig-dev ruby-dev rubygems 	\
		libopenssl-ruby libdbd-mysql-ruby libmysql-ruby 				\
		libmagick++-dev zip unzip memcached git-core git-svn git-doc 	\
		git-cvs irb)
		
MISSING_DEPS=()	
for DEP in "${DEPS[@]}"; do
	if  ! dpkg --get-selections | grep --quiet $DEP 
	then
		MISSING_DEPS+=("$DEP")
	fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]
then
	echo "You are missing: "
	for MISSING_DEP in "${MISSING_DEPS[@]}"; do
		echo $MISSING_DEP
	done
fi

## Install the Ruby Gems
REALLY_GEM_UPDATE_SYSTEM=1 gem update --system

gem install --no-ri --no-rdoc -v 0.8.7 rake
gem install --no-ri --no-rdoc -v 1.1.0 daemons
gem install -b --no-ri --no-rdoc rmagick stompserver passenger bundler


