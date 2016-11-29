#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is server registered with RHN?
####
if [ "$distro" == "RHEL" ]; then 
	echo -en " Registered with RHN\t"
	if [ -f /etc/sysconfig/rhn/systemid	]; then

		echo_success; echo

	else

		echo_failure; echo
		exit 255 

	fi
fi

####
# Is server up to date?
####

echo -en " System is up to date\t"

if [ "$distro" = "Ubuntu" ]; then
	if [ -x /usr/lib/update-notifier/apt-check ]; then
		# First, update package list
		apt-get update > /dev/null 2>&1
		updates=$(/usr/lib/update-notifier/apt-check --human-readable | head -1 | cut -d" " -f1)
		# Just make the return code equal to the number of updates
		RETVAL=$updates
	fi
elif which yum >/dev/null 2>&1; then
	yum -q check-update > /dev/null 2>&1
	RETVAL=$?
else
	# Can't find update manager
	RETVAL=255
fi

if [ $RETVAL -eq 0 ]; then
	echo_success; echo
else
	# the CLONE_ENV variable is set by
	# #DOMAIN#-firstboot.sh
	if [ "${CLONE_ENV:-"0"}" == "0" ]; then
		echo_failure; echo
		exit 255
	else
		echo_warning; echo
	fi
fi

# All is well
exit 0
