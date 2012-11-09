#!/bin/bash

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



