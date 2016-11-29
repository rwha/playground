#!/bin/bash


# Include result.sh for pretty output
. ./result.sh

# View contents of /etc/resolv.conf 

resolv=$(grep -c "8.8.[48].[48]$" /etc/resolv.conf)

echo -en " /etc/resolv.conf is configured\t"
if [ ${resolv} -eq 2 ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi
