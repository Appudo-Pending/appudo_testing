#!/bin/bash
COUNT=999
./websocket_csd.sh &>/dev/null &
while true; do
	if [ $COUNT -eq 0 ]; then
		exit 1
	fi
	COUNT=$(($COUNT-1))
	./testrunner.sh -r -j -a -sWebSocket -f./results -Gpropfile=settings.properties -t./tests/global.settings.xml ./tests/appudo.xml
done
