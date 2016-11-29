#!/bin/bash


# Include result.sh for pretty output
. ./result.sh


####
# Is QMail installed?
####

echo -en " QMail is installed\t"
if [ -d /var/qmail/control	]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


####
# Is QMail running?
####

running=$(/command/svstat /service/qmail/ | grep -c ": up")

echo -en " QMail is running\t"
if [ "${running}" == "1" ]; then

	time=$(/command/svstat /service/qmail/ | awk '{ print $5}')

	if	[ ${time:=0} -gt 10 ]; then

		echo_success; echo

	else

		echo_failure; echo
		exit 255 

	fi

else

	echo_failure; echo
	exit 255 

fi



####
# Is SMTP running?
####

running=$(/command/svstat /service/smtpd/ | grep -c ": up")

echo -en " SMTP is running\t"
if [ "${running}" == "1" ]; then

	time=$(/command/svstat /service/smtpd/ | awk '{ print $5}')

	if	[ ${time:=0} -gt 10 ]; then

		echo_success; echo

	else

		echo_failure; echo
		exit 255 

	fi	

else

	echo_failure; echo
	exit 255 

fi


####
# Is POP3 running?
####

running=$(/command/svstat /service/pop3d/ | grep -c ": up")

echo -en " POP3 is running\t"
if [ "${running}" == "1" ]; then

	time=$(/command/svstat /service/pop3d/ | awk '{ print $5}')

	if	[ ${time:=0} -gt 10 ]; then

		echo_success; echo

	else

		echo_failure; echo
		exit 255 

	fi	

else

	echo_failure; echo
	exit 255 

fi



####
# Is VPOPMail installed?
####

echo -en " VPOPMail is installed\t"
if [ -f /home/vpopmail/bin/vadddomain ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


####
# Setup info for mail tests
####

testdomain=#DOMAIN#



####
# Test mail to test domain
####


# Make sure it is not already created!
checkdom=$(/home/vpopmail/bin/vdominfo -n ${testdomain})

if [ "${checkdom}" != "Invalid domain name" ]; then

	echo -en " Test domain (${testdomain}) already exists\t"
	echo_failure; echo
	exit 255 

fi


# Create domain
/home/vpopmail/bin/vadddomain ${testdomain} test

checkdom=$(/home/vpopmail/bin/vdominfo -n ${testdomain})

echo -en " Create ${testdomain}\t"
if [ "${checkdom}" == "${testdomain}" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi


# Send Test Message
echo "This is a test of Qmail" | mail -s test postmaster@${testdomain}
sleep 2

maildir="$(/home/vpopmail/bin/vdominfo -d ${testdomain})"

mail_delivered=$(grep -c "This is a test of Qmail" ${maildir}/postmaster/Maildir/new/*)


echo -en " Mail was delivered\t"
if [ ${mail_delivered} -gt 0 ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


# Remove Domain
/home/vpopmail/bin/vdeldomain ${testdomain}

checkdom=$(/home/vpopmail/bin/vdominfo -n ${testdomain})

echo -en " Delete ${testdomain}\t"
if [ "${checkdom}" == "Invalid domain name" ]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi

