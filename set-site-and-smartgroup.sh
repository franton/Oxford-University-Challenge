#!/bin/bash

# Script to create a JSS Site and accompanying smart group to show all Yosemite based computers

# Author  : Richard Purves <contact@richard-purves.com>
# Version : 1.0 - 30-09-2014 - Initial Version

# Set variables here

apiuser=""
apipass=""
apiurl=`/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url`

site=$4

# Some error checking as we're reliant on info being passed to the script.

if [ "$site" == "" ]; then
	echo "Error: Missing site name. Please add info to policy/remote command and try again."
	exit 1
fi

# Create a Site from the supplied information.

cat <<EOF > /var/tmp/siteupload.xml
<site>
  <name>$site</name>
</site>
EOF

# Use the Casper 9 API to create a new site as supplied from parameter 4

curl -X POST --insecure --silent --user ${apiuser}:${apipass} ${apiurl}JSSResource/sites/id/0 -d @/var/tmp/siteupload.xml --header "Content-Type:text/xml"

# Now create the Site specific Yosemite detecting smart group
# To do this we need to generate a separate xml file for curl to get to grips with

cat <<EOF > /var/tmp/groupupload.xml
<computer_group>
  <name>$site 10.10 Clients</name>
  <is_smart>true</is_smart>
  <site>
    <name>$site</name>
  </site>
  <criteria>
    <criterion>
      <name>Operating System</name>
      <priority>0</priority>
      <and_or>and</and_or>
      <search_type>like</search_type>
      <value>10.10.0</value>
    </criterion>
  </criteria>
</computer_group>
EOF

# Now upload the xml file to the JSS.

curl -X POST --insecure --silent --user ${apiuser}:${apipass} ${apiurl}JSSResource/computergroups/id/0 -d @/var/tmp/groupupload.xml --header "Content-Type:text/xml"

# Completed!

exit 0
