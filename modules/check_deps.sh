#!/bin/bash

## This section will check necessary dependecies
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
