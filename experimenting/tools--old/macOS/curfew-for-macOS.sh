#!/bin/bash

blacklist="qrowser Chrome Chromium firefox afari Messenger LINE Store"
BannedURL[1]="www.facebook.com"
BannedURL[2]="www.instagram.com"
BannedURL[3]="www.youtube.com"

FunTimeStarts=194000
FunTimeEnds=200000
CurfewStarts=210000
CurfewEnds=090000

BanSites() { # THIS IS WRONG! FUNCTIONS and ARRAYS are harder to deal with! Document it !
	for object in "${BannedURL[@]}"; do # This for-loop is never implemented
		cat "/etc/hosts" | grep "$object"
		if [[ $? == 1 ]]; then
			echo "127.0.0.1 "$object"" >> /etc/hosts
		fi
	done
}

UnBanSites() { # THIS IS WRONG! FUNCTIONS and ARRAYS are harder to deal with! Document it!
	echo "Mom, I am here!" # This line, however, is implemented

	for object in "${BannedURL[@]}"; do # This for-loop is never implemented
		echo "Site "$object" unbanned!"
		sed -i -e "/$object/d" /etc/hosts
	done
}

while [[ $(date +%u) -le 7 ]] #weekdays+weekend
do
	now=$(date +"%H%M%S")
	if ! [[ $now > $FunTimeStarts && $now < $FunTimeEnds ]]; then
		echo "KILL at $now!" >> /Users/dai/Desktop/curfew-log.txt
		pkill $blacklist # Cannot add ".." around $blacklist. Somehow pkill just does not buy it!
		BanSites ; echo "Ban sites at $now!" >> /Users/dai/Desktop/curfew-log.txt
	else
		UnBanSites ; echo "Unban sites at $now!" >> /Users/dai/Desktop/curfew-log.txt
	fi

	if ! [[ $now > $CurfewEnds && $now < $CurfewStarts ]]; then
	echo something
	#pkill loginwindow 2>> /Users/jin/Desktop/error.log 1>> /Users/jin/Desktop/stdout.log
	fi
	sleep 5
done

exit
