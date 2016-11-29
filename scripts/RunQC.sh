#!/bin/bash

# Now we can run it from anywhere!
cd $( dirname $0 )

# Make function to check return status of tests
chkfail() {
if [ $? -ne 0 ]; then
	FAIL=Y
fi
}

# Set initial value
FAIL=N


if [ -f /etc/ROLE ]; then
	# get role (values: WEB, DB, WEBDB, MIN, MAIL)
	role=$(cat /etc/ROLE | awk -F: '{print $1}')
	# get backup role (values "", BKUP, REMOTE)
	bkrole=$(cat /etc/ROLE | awk -F: '{print $2}')
else
	#default to MAIL
	role=MAIL
	bkrole="BKUP"
fi


####
# Get some basic info
####

# Check the Linux Distro and export for scripts to use
if [ -e /etc/redhat-release ] && [ "$(grep -c "Red Hat Enterprise Linux" /etc/redhat-release)" -ge 1 ]; then
	distro="RHEL"
	releaseVer="$(sed 's/Update/./; s/[^0-9.]//g' /etc/redhat-release)"
	releaseName="$(sed 's/^.*(\([^ )]*\).*$/\1/' /etc/redhat-release)"
elif [ -e /etc/redhat-release ] && [ "$(grep -c "CentOS" /etc/redhat-release)" -ge 1 ]; then
	distro="CentOS"
	releaseVer="$(sed 's/Update/./; s/[^0-9.]//g' /etc/redhat-release)"
	releaseName="$(sed 's/^.*(\([^ )]*\).*$/\1/' /etc/redhat-release)"
elif [ -x /usr/bin/lsb_release ]; then
	distro="$(/usr/bin/lsb_release -si)"
	if [ "$distro" = "Ubuntu" ]; then
		# We want the point release which is in the description not the release on Ubuntu
		releaseVer="$(/usr/bin/lsb_release -sd | sed "s/${distro} //; s/ LTS//")"
	else
		releaseVer="$(/usr/bin/lsb_release -sr)"
	fi
	releaseName="$(/usr/bin/lsb_release -sc)"
else
	distro=$OS
fi

export distro

hostname=$HOSTNAME
os=`uname`
version=`cat /etc/redhat-release`
kernel=`uname -r`
arch=`uname -i`
IP=`grep "IPADDR" /etc/sysconfig/network-scripts/ifcfg-eth0 |cut -d "=" -f 2`
netmask=`grep "NETMASK" /etc/sysconfig/network-scripts/ifcfg-eth0 |cut -d "=" -f 2`
gateway=`cat /etc/sysconfig/network |grep "GATEWAY" |cut -d "=" -f 2`


####
# Run tests, report findings
####

printf "[ ServerName ]\n"
printf " $hostname\n"
printf " $version ($arch)\n"
printf " Role: ${role}\n"

if [ "${bkrole}" == "BKUP" ]; then
	printf " Backup Role: ${bkrole}\n"
fi

printf "\n"

printf "[ resolv.conf contents ]\n"
cat /etc/resolv.conf | sed 's/^/ /'
printf "\n"

printf "[ Network Information ]\n"
printf " IP Address:\t\t$IP\n"
printf " Gateway:\t\t$gateway\n"
printf " Netmask:\t\t$netmask\n"
printf "\n"

printf "[ NRPE Information ]\n"
sh ./nrpe.sh; chkfail
printf "\n"

printf "[ Perl Information ]\n"
sh ./perl.sh; chkfail
printf "\n"

printf "[ SSH Information ]\n";
sh ./ssh.sh; chkfail
printf "\n"

printf "[ NTPD Information ]\n"
sh ./ntpd.sh; chkfail
printf "\n"

printf "[ Update Information ]\n"
sh ./rhn.sh; chkfail
printf "\n"

# Check Web related stuff, if applicable
if [ "${role}" == "WEB" ] || [ "${role}" == "WEBDB" ] || [ "${role}" == "MAIL" ]; then
	printf "[ Apache Information ]\n"
	sh ./apache.sh; chkfail
	printf "\n"

	printf "[ PHP Information ]\n"
	sh ./php.sh; chkfail
	printf "\n"
fi


# Check DB related stuff, if applicable
if [ "${role}" == "DB" ] || [ "${role}" == "WEBDB" ] || [ "${role}" == "MAIL" ]; then
	printf "[ MySQL Information ]\n"
	sh ./mysql.sh; chkfail
	printf "\n"
fi


# Check Mail related stuff, if applicable
if [ "${role}" == "MAIL" ]; then
	printf "[ Qmail Information ]\n"
	sh ./qmail.sh; chkfail
	printf "\n"

	printf "[ Horde Information ]\n"
	sh ./horde.sh; chkfail
	printf "\n"

	printf "[ QmailAdmin Information ]\n"
	sh ./qmailadmin.sh; chkfail
	printf "\n"
fi


# Check on Bacula if needed
if [ "${bkrole}" == "BKUP" ]; then
	printf "[ Bacula and MySQL for Bacula information ]\n"
	sh ./bacula.sh; chkfail
	printf "\n"
fi


printf "[ /etc/resolv.conf Information ]\n"
sh ./resolv.sh; chkfail
printf "\n"


printf "[ Network Configuration ]\n"
sh ./ip.sh; chkfail
printf "\n"

# unset env variables
unset CLONE_ENV

if [ "${FAIL}" == "N" ]; then
	echo "$HOSTNAME has passed this Quality Control Check"
	echo
	exit 0
else
	echo "$HOSTNAME has FAILED this Quality Control Check"
	echo
	exit 255
fi

