#!/bin/bash
## Set up the databases
mv config/boot.rb config/boot.rb.orig
echo "require 'thread'" > config/boot.rb
cat config/boot.rb.orig >> config/boot.rb

su - git -c 'bundle install'
su - git -c 'bundle pack'
su - git -c 'rake db:migrate RAILS_ENV=production'
su - git -c 'rake ultrasphinx:bootstrap RAILS_ENV=production'

echo "* * * * * cd /var/www/gitorious && /usr/bin/bundle exec rake ultrasphinx:index RAILS_ENV=production" \
	>> /var/spool/cron/crontabs/git

chown git:crontab /var/spool/cron/crontabs/git
chmod 600 /var/spool/cron/crontabs/git

env RAILS_ENV=production ruby1.8 script/create_admin
