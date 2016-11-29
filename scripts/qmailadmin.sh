#!/bin/bash

# Include result.sh for pretty output
. ./result.sh

# Check if QMailAdmin is installed

echo -en " QMailAdmin is installed\t"
if [ -f /var/www/cgi-bin/qmailadmin ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi

# All is well
exit 0

