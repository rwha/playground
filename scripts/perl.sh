#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is perl installed?
####

if [ -f /usr/bin/perl ]; then

	version=$(/usr/bin/perl -v |head -2 |sed	'/^$/d' |awk {'print $4'}|sed 's/v//g')
	echo -en " Perl ${version} is installed\t"
	echo_success; echo

else

	echo -en " Perl is installed\t"
	echo_failure; echo
	exit 255 

fi


