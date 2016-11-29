#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is Horde installed?
####

echo -en " Horde is installed\t"
if [ -d /var/www/html/horde	]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi
