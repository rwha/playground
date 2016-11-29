#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is sshd installed?
####

echo -en " SSH is installed\t"
if [ -f /usr/sbin/sshd ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is sshd running?
####

sshd_running=`service sshd status | grep -c "running"`

echo -en " SSH is running\t"
if [ ${sshd_running} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is sshd starting on boot?
####

sshd_chkconfig=`chkconfig --list sshd |grep -c "3:on"`

echo -en " SSH is set to start on boot\t"
if [ ${sshd_chkconfig} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi

# All is well
exit 0

