#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is Apache installed?
####

if [ -f /usr/sbin/httpd ]; then
	version=$(/usr/sbin/httpd -V |head -1 |awk '{print $3}' |cut -d '/' -f 2)
	echo -en " Apache ${version} is installed\t"
	echo_success; echo
else
	echo -en " Apache is installed\t"
	echo_failure; echo
	exit 255 
fi


####
# Is Apache running?
####

httpd_running=`service httpd status | grep -c "running"`

echo -en " Apache is running\t"
if [ ${httpd_running} == "1" ]; then
	echo_success; echo
else
	echo_failure; echo
	exit 255 
fi


####
# Is Apache starting on boot?
####

httpd_chkconfig=`chkconfig --list httpd |grep -c "3:on"`

echo -en " Apache is set to start on boot\t"
if [ ${httpd_chkconfig} == "1" ]; then
	echo_success; echo
else
	echo_failure; echo
	exit 255
fi

# All is well
exit 0
