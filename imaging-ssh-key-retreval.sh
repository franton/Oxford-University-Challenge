#!/bin/bash

# Imaging script to find RSA public key from JSS and program computer with it

# Author  : Richard Purves <contact@richard-purves.com>
# Version : 1.0 - 29-09-2014 - Initial Version

apiuser=""
apipass=""
apiurl=`/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url`
volpath="/Volumes/Macintosh HD/"
ethernet=$(ifconfig en0|grep ether|awk '{ print $2; }')

# Grab current inventory record for this client from the JSS

cmd="curl --insecure --silent --user ${apiuser}:${apipass} --request GET ${apiurl}JSSResource/computers/macaddress/${ethernet//:/.}"
hostinfo=$( ${cmd} )

# Now let's slice the hostinfo variable down into what we want.
# From that, we can store into another variable.

rsastoredkey=${hostinfo##*RSA Key\<\/name\><type>String</type><value>}
rsastoredkey=${rsastoredkey%%\<\/value\>*}

dsastoredkey=${hostinfo##*DSA Key\<\/name\><type>String</type><value>}
dsastoredkey=${dsastoredkey%%\<\/value\>*}

sshstoredkey=${hostinfo##*SSH Key\<\/name\><type>String</type><value>}
sshstoredkey=${sshstoredkey%%\<\/value\>*}

# Check to see if there's anything present, if so then program up the files otherwise skip.

if [ -n "$rsastoredkey" ] || [ -n "$dsastoredkey" ] || [ -n "$sshstoredkey" ];
then

	echo "No existing SSH public keys present. Exiting."
	exit 1

else

	# Create the ssh public key files

	touch "$volpath"/etc/ssh_host_rsa_key.pub
	touch "$volpath"/etc/ssh_host_dsa_key.pub
	touch "$volpath"/etc/ssh_host_key.pub

	# Read the contents of the variables into the files

	echo $rsastoredkey > "$volpath"/etc/ssh_host_rsa_key.pub
	echo $dsastoredkey > "$volpath"/etc/ssh_host_dsa_key.pub
	echo $sshstoredkey > "$volpath"/etc/ssh_host_key.pub

	# Set the ownership and permissions correctly

	chmod 644 "$volpath"/etc/ssh_host_rsa_key.pub
	chmod 644 "$volpath"/etc/ssh_host_dsa_key.pub
	chmod 644 "$volpath"/etc/ssh_host_key.pub

	chown root:wheel "$volpath"/etc/ssh_host_rsa_key.pub
	chown root:wheel "$volpath"/etc/ssh_host_dsa_key.pub
	chown root:wheel "$volpath"/etc/ssh_host_key.pub

fi

exit 0
