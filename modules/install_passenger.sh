#!/bin/bash
#$(gem contents passenger | grep passenger-install-apache2-module)
MOD_PASSENGER_LOC=`find /usr/lib/ruby/gems -name mod_passenger.so`
PASSENGER_DIR=`find /usr/lib/ruby/gems -type d -name passenger-*`
cat <<EOF > /etc/apache2/mods-available/passenger.load
LoadModule passenger_module ${MOD_PASSENGER_LOC}
   PassengerRoot ${PASSENGER_DIR}
   PassengerRuby /usr/bin/ruby1.8
EOF

cat /etc/apache2/mods-available/passenger.load

