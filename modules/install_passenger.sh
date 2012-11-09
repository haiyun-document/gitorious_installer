#!/bin/bash
$(gem contents passenger | grep passenger-install-apache2-module)
MOD_PASSENGER_LOC=`find /usr/lib/ruby/gems -name mod_passenger.so`

cat <<EOF > /etc/apache2/mods-available/passenger.load
LoadModule passenger_module ${MOD_PASSENGER_LOC}
   PassengerRoot /usr/lib/ruby/gems/1.8/gems/passenger-3.0.18
   PassengerRuby /usr/bin/ruby1.8
EOF

cat /etc/apache2/mods-available/passenger.load

