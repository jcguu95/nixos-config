#!/bin/sh
## This is a battery logger I wrote for testing battery bought from ebay / yahoo.

logFile="$HOME/bat_log.txt"

while true; do
	date -Is >> "$logFile"
	cat /sys/class/power_supply/BAT0/capacity 2>>"$logFile" >> "$logFile"
	sleep 15
done

exit
