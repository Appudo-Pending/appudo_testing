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
#cleanup
rm -f ./tests/appudo.scon*.xml
rm -f ./tests/settings.scon*.properties
rm -rf ./tests/results.scon*
#create runs
./testrunner.sh -r -j -a -sConcurrent_Single_Up -f./results -Gpropfile=settings.properties -t./tests/global.settings.xml ./tests/appudo.xml
COUNT=0
while [  $COUNT -lt $NUM ]; do
	#copy appudo.xml for each run
	cp ./tests/appudo.xml ./tests/appudo.scon$COUNT.xml
	#create output folder for each run
	mkdir ./tests/results.scon$COUNT
	#create settings.properties for each run
        cp ./tests/settings.properties ./tests/settings.scon$COUNT.properties
	#remove props
	sed -i /suffix/d ./tests/settings.scon$COUNT.properties
        sed -i /loginPassword/d ./tests/settings.scon$COUNT.properties
        sed -i /loginName/d ./tests/settings.scon$COUNT.properties
	sed -i /pageURL/d ./tests/settings.scon$COUNT.properties
	#set props
	echo "suffix=scon$COUNT" >> ./tests/settings.scon$COUNT.properties
	echo "loginName=scon$COUNT" >> ./tests/settings.scon$COUNT.properties
        echo "loginPassword=scon$COUNT" >> ./tests/settings.scon$COUNT.properties
	echo "pageURL=testscon$COUNT" >> ./tests/settings.scon$COUNT.properties
	#run in parralel
	./testrunner.sh -r -j -a -sTests -f./tests/results.scon$COUNT -Gpropfile=settings.scon$COUNT.properties -t./tests/global.settings.xml ./tests/appudo.scon$COUNT.xml &
	pids="$pids $!"
	COUNT=$(($COUNT+1))
done
#wait
wait $pids
COUNT=0
while [  $COUNT -lt $NUM ]; do
	#collect, rename and merge results
	mv ./tests/results.scon$COUNT/*.xml ./results/result.scon$COUNT.xml
	COUNT=$(($COUNT+1))
done

