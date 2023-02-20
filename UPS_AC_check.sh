#!/bin/bash

##exit;

########## USAGE BEGIN ##########
# Two ways:
## One to run the script for infnite loop, put it in rcS.d or rc.local
### Set LOOP=1 and LOOP_GAP=120
## Another to run the script under crontab, set it execute every 2 minutes
### Set LOOP=0
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
##*/2 * * * * root /pub/sh/luis_cron.ups.check.sh 
########## USAGE END ##########

########## CONFIG BEGIN ##########
# set DEBUG to 0 for echo debug
# set DEBUG to 1 for syslog to /var/log/messages
DEBUG=0

# set LOOP to 0 for do it once
# set LOOP to 1 for endless loop
LOOP=0
# time gap between LOOP, seconds
LOOP_GAP=120
########## CONFIG END ##########

LOG='/usr/bin/logger'
SDFILE='/run/systemd/shutdown/scheduled'
GWIP='192.168.8.250'

while true
do
	
	let N=0
	for x in `/sbin/route | grep default`
	do
		if [ $N -eq 1 ]; then
			GWIP=$x
			break
		fi
		let N=N+1
	done

	if [ $DEBUG -eq 1 ]; then
		echo "Luis_UPS: >>> GWIP ${GWIP}"
	else
		$LOG "Luis_UPS: >>> GWIP ${GWIP}"
	fi

	ping -w 5 -c 1 $GWIP > /dev/null

	ret=$?
		if [ $ret -eq 0 ]; then
			# $ret = 0
			# router is OK
			if [ $DEBUG -eq 1 ]; then
				echo "Luis_UPS: ... AC OK!"
			else
				$LOG "Luis_UPS: ... AC OK!"
			fi
			
			pscnt=`ps aux | grep shutdown | grep -v grep | wc -l`
			if [ $pscnt -gt 0 ]; then
				if [ $DEBUG -eq 1 ]; then
					echo "Luis_UPS: ... AC Recovered! Cancel shutdown! ${pscnt}"
				else
					$LOG "Luis_UPS: ... AC Recovered! Cancel shutdown!"
					/sbin/shutdown -c "Luis_UPS: AC Power Recovered! Cancel shutdown!" &
				fi
			fi
		else
			# $ret = 1
			# if router fail, it means 220V is down, or network is down
			#pscnt=`ps aux | grep shutdown | grep -v grep | wc -l`
            if test -f "${SDFILE}"; then
			    pscnt=`cat ${SDFILE} | wc -l`
            else
                pscnt=0
            fi

			if [ $pscnt -eq 0 ]; then
				# if no shutdown in progress, then shutdown
				if [ $DEBUG -eq 1 ]; then
					echo "Luis_UPS: ... AC Failed! Shutdown in 5 mins! ${pscnt}"
				else
					$LOG "Luis_UPS: ... AC Failed! Shutdown in 5 mins!"
					/sbin/shutdown -h 5 "Luis_UPS: AC Power Failed! Ready to shutdown!" &
				fi
			fi
		fi

	if [ $LOOP -eq 1 ]; then
		sleep $LOOP_GAP
	else
		break
	fi
	
done
