#!/bin/bash

# Include result.sh for pretty output
. ./result.sh


####
# Function to check if an IP is valid
# rwhalen v2.0
####
function checkip {
	checkip=$1

		result="pass"

		if [ ! $(echo $checkip | egrep "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$") ]; then
			result="fail"
		else
			result=$(echo $checkip | awk -F. '{for (x = 1; x <= NF; x++) if ($x > 255 ) {print "fail"; break}}')
		fi

### IP is good, value contained in $checkip ###
		if [ "$result" != "fail" ]; then
			checkedip="VALID"
		else
			checkedip="INVALID"
		fi

}


####
# Get configured IP
####

confip=$(grep "IPADDR" /etc/sysconfig/network-scripts/ifcfg-eth0 |cut -d "=" -f 2)

checkip ${confip}

echo -en " Static IP configured\t"
if [ "${checkedip}" == "VALID"	]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255 

fi

####
# Check Netmask
####

netmask=$(grep "NETMASK" /etc/sysconfig/network-scripts/ifcfg-eth0 |cut -d "=" -f 2)

checkip ${netmask}


echo -en " Netmask configured\t"
if [ "${checkedip}" == "VALID"	]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi



####
# Check Gateway
####

gateway=$(cat /etc/sysconfig/network |grep "GATEWAY" |cut -d "=" -f 2)

checkip ${gateway}


echo -en " Gateway IP configured\t"
if [ "${checkedip}" == "VALID"	]; then

	echo_success; echo

else

	echo_failure; echo
	exit 255

fi


####
# Get DNS IP, Disabled since DNS takes too long to update
####

#dnsip=$(host $(hostname) | awk {'print $4'})

#checkip ${dnsip}


#echo -en " DNS configured\t"
#if [ "${checkedip}" == "VALID"	]; then

#	echo_success; echo

#else

#	echo_failure; echo
#	exit 255

#fi


####
# Compare IPs
####


#echo -en " Configured IP matches DNS\t"
#if [ "${confip}" == "${dnsip}" ]; then

#	echo_success; echo

#else

#	echo_failure; echo
#	exit 255

#fi

# All is well
exit 0
