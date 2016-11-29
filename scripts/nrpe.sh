#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is nrpe installed?
####

if [ -f /usr/local/nagios/bin/nrpe	]; then

	version=$(/usr/local/nagios/bin/nrpe -V | awk '/Version/ {print $2}')
	echo -en " NRPE ${version} is installed\t"
	echo_success; echo

else

	echo -en " NRPE is installed\t"
	echo_failure; echo
	exit 255 

fi


####
# Is nrpe running?
####

nrpe_running=`service nrpe status | grep -c "running"`

echo -en " NRPE is running\t"
if [ ${nrpe_running} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is nrpe starting on boot?
####

nrpe_chkconfig=`chkconfig --list nrpe |grep -c "3:on"`

echo -en " NRPE is set to start on boot\t"
if [ ${nrpe_chkconfig} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi

# All is well
exit 0
