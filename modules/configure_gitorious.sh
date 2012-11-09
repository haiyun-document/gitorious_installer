#!/bin/bash

## Install correct gems
cd /var/www/gitorious
bundle install
bundle pack

## Create user git
adduser --system --home /var/www/gitorious/ --no-create-home --group --shell /bin/bash git && \
	chown -R git:git /var/www/gitorious
cat <<EOF >> /etc/sudoers
 
## User git
git    ALL = NOPASSWD: ALL
EOF

## Configuration files
cp config/database.sample.yml config/database.yml
cp config/gitorious.sample.yml config/gitorious.yml
cp config/broker.yml.example config/broker.yml

sed -i 's/\/var\/git\/repositories/\/var\/www\/gitorious\/repositories/g' /var/www/gitorious/config/gitorious.yml 
