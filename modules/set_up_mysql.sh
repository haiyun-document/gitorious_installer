#!/bin/bash

## Get root password
read -s -p "Enter mysql root password: " MYSQL_PASSWD
echo \n
## Create gitorious_production database
mysql -u root -p"${MYSQL_PASSWD}" -e "CREATE DATABASE gitorious_production"
