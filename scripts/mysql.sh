#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is mysql installed?
####

if [ -f /usr/bin/mysqld_safe ]; then

	version=$(mysql -V |awk {'print $5'} | sed 's/,//')
	echo -en " MySQL ${version} is installed\t"
	echo_success; echo

else

	echo -en " MySQL is installed"
	echo_failure; echo
	exit 255 

fi


####
# Is mysql running?
####

mysql_running=`service mysqld status | grep -c "running"`

echo -en " MySQL is running\t"
if [ ${mysql_running} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is mysql starting on boot?
####

mysql_chkconfig=`chkconfig --list mysqld |grep -c "3:on"`

echo -en " MySQL is set to start on boot\t"
if [ ${mysql_chkconfig} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi

# All is well
exit 0

