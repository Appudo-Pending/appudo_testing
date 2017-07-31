#!/bin/bash
pids=""
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
NUM=$(cat tests/settings.properties | grep numConcurrent)
NUM="$((${NUM:14}))"
URL=$(cat tests/settings.properties | grep concurrentURL)
URL="${URL:14}"
#cleanup
rm -f ./tests/concurrent/*
rm -f ./tests/appudo.con*.xml
rm -f ./tests/settings.con*.properties
rm -rf ./tests/results.con*
#create accounts
./testrunner.sh -r -j -a -sConcurrent_Up -f./results -Gpropfile=settings.properties -t./tests/global.settings.xml ./tests/appudo.xml
COUNT=0
while [  $COUNT -lt $NUM ]; do
	#copy appudo.xml for each run
	cp ./tests/appudo.xml ./tests/appudo.con$COUNT.xml
	#create output folder for each run
	mkdir ./tests/results.con$COUNT
	#create settings.properties for each run
        cp ./tests/settings.properties ./tests/settings.con$COUNT.properties
	#remove props
	sed -i /baseURL/d ./tests/settings.con$COUNT.properties
	sed -i /apiURL/d ./tests/settings.con$COUNT.properties
	sed -i /loginPassword/d ./tests/settings.con$COUNT.properties
	sed -i /loginName/d ./tests/settings.con$COUNT.properties
	sed -i /accountID/d ./tests/settings.con$COUNT.properties
	sed -i /userID/d ./tests/settings.con$COUNT.properties
	sed -i /userGID/d ./tests/settings.con$COUNT.properties
	sed -i /runnerGID/d ./tests/settings.con$COUNT.properties
	sed -i /suffix/d ./tests/settings.con$COUNT.properties
        sed -i /pageURL/d ./tests/settings.con$COUNT.properties
	#set props
	echo "baseURL=con$COUNT.$URL" >> ./tests/settings.con$COUNT.properties
        echo "apiURL=con$COUNT.$URL" >> ./tests/settings.con$COUNT.properties
	echo "loginName=con$COUNT" >> ./tests/settings.con$COUNT.properties
        echo "loginPassword=con$COUNT" >> ./tests/settings.con$COUNT.properties
	echo "suffix=con$COUNT" >> ./tests/settings.con$COUNT.properties
        echo "pageURL=test123con$COUNT" >> ./tests/settings.con$COUNT.properties
	cat "./tests/concurrent/con$COUNT" >> ./tests/settings.con$COUNT.properties
	#run in parralel
	./testrunner.sh -r -j -a -sTests -f./tests/results.con$COUNT -Gpropfile=settings.con$COUNT.properties -t./tests/global.settings.xml ./tests/appudo.con$COUNT.xml &
	pids="$pids $!"
	COUNT=$(($COUNT+1))
done
#wait
wait $pids
COUNT=0
while [  $COUNT -lt $NUM ]; do
	#collect, rename and merge results
	mv ./tests/results.con$COUNT/*.xml ./results/result.con$COUNT.xml
	COUNT=$(($COUNT+1))
done
#remove accounts
./testrunner.sh -r -j -a -sConcurrent_Down -f./results -Gpropfile=settings.properties -t./tests/global.settings.xml ./tests/appudo.xml

