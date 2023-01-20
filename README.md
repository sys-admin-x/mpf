# MPF
MDM protocol fix

This is a fix for Mosyle ticket #184330 where the MDM protocol would stop responding, resulting in profiles not being pushed to the client.

The script:
* Fetches the time of the last profile sync
* Checks the timestamp of the last install log entry (after filtering out noise)
* If the last profile sync has not occurred in the past 8 hours and nothing is currently installing the software update daemon is restarted.

The packaged version installs a launch daemon and a script in /Library/PrivilegedHelperTools/. The launch daemon runs the script on the 10th minute of every hour.
