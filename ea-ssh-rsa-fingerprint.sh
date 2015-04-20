#!/bin/bash

# EA to find and report the current system SSH fingerprint

# Author  : Richard Purves <contact@richard-purves.com>
# Version : 1.0 - 29-09-2014 - Initial Version

# Set up variables here

syspubkeyloc="/etc/ssh_host_rsa_key.pub"

# Use ssh-keygen tool to read public key into a variable, in a more user friendly format

currentkey=$( cat $syspubkeyloc )

# Echo this out to the JSS

echo "<result>${currentkey}</result>"

exit 0
