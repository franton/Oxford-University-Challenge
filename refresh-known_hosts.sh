#!/bin/bash

# Script to interrogate JSS for all computer names and then program them into the known_hosts file
# This assumes that the computer name is also it's hostname.

# Author  : Richard Purves <contact@richard-purves.com>
# Version : 1.0 - 29-09-2014 - Initial Version
# 			with thanks to Frogor on ##osx-server who helped my awk'ing below.

apiuser=""
apipass=""
apiurl=`/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url`
ethernet=$(ifconfig en0|grep ether|awk '{ print $2; }')

# Grab current inventory record for this client from the JSS

cmd="curl --insecure --silent --user ${apiuser}:${apipass} --request GET ${apiurl}JSSResource/computers"
hostinfo=$( ${cmd} )

# We now have to extract all the computer names and feed them into an array for processing

# Get the names! They should be separated properly if IFS has been set correctly.

jsshostnames=$(echo $hostinfo | xpath '//name' 2>&1 | awk -F'<name>|</name>' '/name>/ {print $2}' | awk '{print $0","}' | tr -d '\n')

# We need to alter IFS to compensate by using only allowing a newline to split the lines

OIFS=$IFS
IFS=$','

# Feed the names into the array

read -a array <<< "$jsshostnames"

# Set IFS back to normal

IFS=$OIFS

# Process the array, making sure the known_hosts file actually exists first.

[ -e /var/root/.ssh/known_hosts ] || touch /var/root/.ssh/known_hosts

for (( loop=0; loop<=${#array[@]}; loop++ ))
do

# The only and BIG problem with this method, is that the target computer has to be online
# for this to work, or it will spend 30+ seconds timing out.

    ssh-keygen -R $host -f /var/root/.ssh/known_hosts
    ssh -q -o StrictHostKeyChecking=no -o BatchMode=yes -o UserKnownHostsFile=/var/root/.ssh/known_hosts $host echo '' || true
done

# Correct permissions on the known_hosts file

chown root:wheel /var/root/.ssh/known_hosts
chmod 755 /var/root/.ssh/known_hosts

# Ok we've got our known_hosts file, but it's only available for root right now.
# Let's copy first into the user template folder so all subsequent users get it.

mkdir /System/Library/User Template/English.lproj/.ssh
cp /var/root/.ssh/known_hosts /System/Library/User Template/English.lproj/.ssh/

# And now all existing user accounts on the computer need a copy too. Just to be sure.

for Account in `ls /Users`
do
	cp /var/root/.ssh/known_hosts /Users/$Account/.ssh/
done

exit 0
