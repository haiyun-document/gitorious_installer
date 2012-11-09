#!/bin/bash
git clone git://gitorious.org/gitorious/mainline.git /var/www/gitorious
cd /var/www/gitorious
git submodule init
git submodule update

ln -s /var/www/gitorious/script/gitorious /usr/bin
