#!/bin/bash

#########################################################################
# Script to check last profile sync and kickstart softwareupdated if 
# sync occurred too far in the past.
#
#
# Version 1.3
#########################################################################

# Gather current date/hour
currentDateWithHour=$(date "+%Y-%m-%d %H")
currentDateWithHourProfileCompare=$(date -v -5H "+%Y-%m-%d %H")

# Get time of last profile sync
profileDateWithHour=$(date -r /var/db/ConfigurationProfiles/Settings/.profilesAreInstalled "+%Y-%m-%d %H")

# Get timestamp of last install log entry
installTime=$(tail -n 500 /var/log/install.log | grep -v mdmclient | grep -v "Fired early" | grep -v "deferred" | grep -v "client SUUpdateServiceClient" | grep -v "SUOSUServiceDaemon: Removing client" | grep -v "systemSoftware is being set to NO because it can" | grep -v "SoftwareUpdate: Fire periodic check for interval" | grep -v "SoftwareUpdate: Should Check" | grep -v "Failed to get bridge device" | grep -v "error running installation-check script" | grep -v "skipping search for bridgeOS update" | grep -v "softwareupdated: Service connection invalidated" | grep -v "Descriptor has changed since previous download" | grep -v "MSU update is not yet downloaded & prepared" | grep -v "SUOSUPowerEventObserver" | grep -v "SoftwareUpdateNotificationManager" | tail -n 1 | awk '{ print $1" "$2 }')
installTimeClean=${installTime::${#installTime}-9}

logger "ProfileFix: profileDateWithHour $profileDateWithHour"
logger "ProfileFix: installTimeClean $installTimeClean"

# Check to see if profiles have been synced in the past 6 hours
if [[ $currentDateWithHourProfileCompare > $profileDateWithHour ]]
then
	#If the last sync was 6 hours or more, check to see if there is something being installed.
	logger "ProfileFix: Profiles updated over 6 hours ago"
	if [[ $currentDateWithHour > $installTimeClean ]]
	then
		#If the last install activity is over an hour ago kickstart softwareupdate
		/bin/launchctl kickstart -k system/com.apple.softwareupdated
		logger "ProfileFix: kickstarted softwareupdated because profile sync was 6+ hours ago."
	fi
fi

exit 0