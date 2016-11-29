#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is ntpd installed?
####

echo -en " NTPD is installed\t"
if [ -f /usr/sbin/ntpd	]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is ntpd running?
####

ntpd_running=`service ntpd status | grep -c "running"`

echo -en " NTPD is running\t"
if [ ${ntpd_running} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is ntpd starting on boot?
####

ntpd_chkconfig=`chkconfig --list ntpd |grep -c "3:on"`

echo -en " NTPD is set to start on boot\t"
if [ ${ntpd_chkconfig} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


####
# Is NTPD using the #DOMAIN# config?
####

ntpd_config=`grep -c "ntp[123].#DOMAIN#" /etc/ntp.conf`

echo -en " NTPD is using the #DOMAIN# configuration\t"
if [ ${ntpd_config} == "3" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


# All is well
exit 0
