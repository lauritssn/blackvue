# Blackvue
Download videos from BlackVue DR650GW-2CH automatically using this bash script.

In case you see something interesting to be recorded. Touch the side of the Dashcam to initiate a manual recording. The manual recording as well as the previous two normal recordings will be downloaded.

Use for instance cron to run the script. This example runs the cron once an hour.

0 * * * * /bin/bash /opt/scripts/blackvue.sh

Remember to make the script executable:

chmod +x /opt/scripts/blackvue.sh



