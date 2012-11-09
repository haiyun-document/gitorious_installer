#!/bin/bash

cp ../scripts/{git-{daemon,poller,ultraphinx},stomp} /etc/init.d/
chmod 755 /etc/init.d/{git-{daemon,poller,ultrasphinx},stomp}

update-rc.d {git-{daemon,poller,ultrasphinx},stomp} defaults 
