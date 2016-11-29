#!/bin/bash

# Include result.sh for pretty output
. ./result.sh

# Check if PHP is installed

if [ -f /usr/bin/php ]; then

	version=$(/usr/bin/php -v |head -1 |awk {'print $2'})
	echo -en " PHP ${version} is installed\t"
	echo_success; echo

else

	echo -en " PHP is installed\t"
	echo_failure; echo
	exit 255 

fi

# All is well
exit 0
