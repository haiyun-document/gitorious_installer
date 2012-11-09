#!/bin/bash

cp scripts/{git-{daemon,poller,ultrasphinx},stomp} /etc/init.d/
chmod 755 /etc/init.d/{git-{daemon,poller,ultrasphinx},stomp}

update-rc.d git-daemon defaults
update-rc.d git-poller defaults
update-rc.d git-ultrasphinx defaults
update-rc.d stomp defaults
