#!/bin/bash

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
