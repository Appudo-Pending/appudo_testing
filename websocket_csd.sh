#!/bin/bash
COUNT=0
RUNS=0
PENDING=0
while [ true ];
do
	if [ $PENDING -lt 1000 ]; then
		python ./websocket_csd.py "test" "ws://localhost/test123/" &
        fi
	if [ $RUNS -eq 40000 ]; then
		break
	fi
	if [ $COUNT -eq 1000 ]; then
		PENDING=$(ps aux | grep websocket_csd | wc -l)
        	sleep 1
		RUNS=$(($RUNS+1))
		COUNT=0
	else
        	COUNT=$(($COUNT+1))
	fi
done
