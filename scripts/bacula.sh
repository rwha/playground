#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Is there a backup drive?
####

backup_drive=`df -h |grep -c "backup"`

echo -en " /backup mounted\t"
if [ $backup_drive == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


####
# Is bacula installed?
####

echo -en " Bacula is installed\t"
if [ -f /backup/bacula/bconsole	]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is mysql-bacula running?
####

bacula_mysql_running=`ps aux |grep -c "mysql-bacula"`

echo -en " MySQL-Bacula is running\t"
if [ ${bacula_mysql_running} -ge 1 ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


####
# Is bacula running?
####

bacula_running=`service bacula status | grep -c "running"`

echo -en " Bacula is running\t"
if [ ${bacula_running} == "3" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is bacula starting on boot?
####

bacula_chkconfig=`chkconfig --list bacula |grep -c "3:on"`

echo -en " Bacula is set to start on boot\t"
if [ ${bacula_chkconfig} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


####
# Is mysql-bacula starting on boot?
####

bacula_mysql_chkconfig=`chkconfig --list mysqld-bacula | grep -c "3:on"`

echo -en " MySQL-Bacula is set to start on boot\t"
if [ ${bacula_mysql_chkconfig} == "1" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


# All is well
exit 0
