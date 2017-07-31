#!/bin/bash
COUNT=0
BASE=$(cat tests/settings.properties | grep baseURL)
BASE="http://${BASE:8}/dummy"
while true; do
	wget -t1 --timeout=1 $BASE
	if [ $? -eq 8 ]; then
		break
	elif [ $COUNT -eq 360 ]; then
		exit 1
	fi
	COUNT=$(($COUNT+1))
	sleep 1
done
./testrunner.sh -r -j -a -sTests -f./results -Gpropfile=settings.properties -t./tests/global.settings.xml ./tests/appudo.xml
