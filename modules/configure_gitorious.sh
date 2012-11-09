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

COOKIE_SECRET=`apg -d -m 64`

sed -i 's/\/var\/git\/repositories/\/var\/www\/gitorious\/repositories/g' /var/www/gitorious/config/gitorious.yml 
sed -i 's/\/var\/git\/tarballs/\/var\/www\/gitorious\/tarballs/g' /var/www/gitorious/config/gitorious.yml 
sed -i 's/\/var\/git\/tarballs-work/\/tmp\/tarballs-work/g' /var/www/gitorious/config/gitorious.yml 
sed -i 's/ssssht/${COOKIE_SECRET}/g' /var/www/gitorious/config/gitorious.yml 
read -p "Enter server name [git.example.com]: " SERVER_NAME
sed -i 's/gitorious_host: gitorious.test/gitorious_host: ${SERVER_NAME}/g' /var/www/gitorious/config/gitorious.yml 
sed -i 's/#hide_http_clone_urls: false/hide_http_clone_urls: true/g' /var/www/gitorious/config/gitorious.yml 
sed -i 's/#is_gitorious_dot_org: true/is_gitorious_dot_org: false/g' /var/www/gitorious/config/gitorious.yml 
read -p "Enter admin email [admin@example.com]: " ADMIN_EMAIL
sed -i 's/exception_notification_emails:/exception_notification_emails: ${ADMIN_EMAIL}/g' /var/www/gitorious/config/gitorious.yml 

## Private repositories
cat <<EOF
  # Enabling private repositories allows users to control read-access to their
  # repositories. Repositories are public by default, but individual users
  # and/or groups can be given read permissions to limit who can see and pull
  # from individual repositories and/or projects.
  # More information is available in the Gitorious Wiki:
  # https://gitorious.org/gitorious/pages/PrivateRepositories

EOF
read -p "Enable private repositories? [y/N] " ENABLE_PRIVATE
ENABLE_PRIVATE=`echo "${ENABLE_PRIVATE}" | tr '[A-Z]' '[a-z]'`
if [ "${ENABLE_PRIVATE}" = "y" ] ; then
	sed -i 's/#enable_private_repositories: false/enable_private_repositories: true/g' /var/www/gitorious/config/gitorious.yml 
fi

## Public mode
cat <<EOF
  # When Gitorious is running in public mode (true), everyone with access to the
  # server can view and clone repositories. Private mode (false) will not allow
  # anonymous access to content or user registration. Only pre-approved and
  # logged in users can surf the Gitorious installation.

EOF
read -p "Enable private mode? [y/N] " PRIVATE_MODE
PRIVATE_MODE=`echo "${PRIVATE_MODE}" | tr '[A-Z]' '[a-z]'`
if [ "${PRIVATE_MODE}" = "y" ] ; then
	sed -i 's/#public_mode: true/public_mode: false/g' /var/www/gitorious/config/gitorious.yml 
fi

## MySQL password
read -s -p "Enter root password fro mysql" MYSQL_PASSWD
sed -i 's/password:/password: ${MYSQL_PASSWD}/g' /var/www/gitorious/config/database.yml 


## Set up database
mv config/boot.rb config/boot.rb.orig
echo "require 'thread'" > config/boot.rb.orig
cat config/boot.rb.orig >> config.boot.rb

su - git -c 'bundle install'
su - git -c 'bundle pack'
su - git -c 'rake db:migrate RAILS_ENV=production'
su - git -c 'rake ultrasphinx:bootstrap RAILS_ENV=production'

echo "* * * * * cd /var/www/gitorious && /usr/bin/bundle exec rake ultrasphinx:index RAILS_ENV=production" \
	>> /var/spool/cron/crontabs/git

chown git:crontab /var/spool/cron/crontabs/git
chmod 600 /var/spool/cron/crontabs/git

env RAILS_ENV=production ruby1.8 script/create_admin


