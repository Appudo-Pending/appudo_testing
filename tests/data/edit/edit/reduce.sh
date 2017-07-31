#!/bin/bash
COUNT=0
while [ $COUNT -ne 9999 ]; do
	OUT1="$(./JSEditFuzzy -n -r $COUNT ./commandsY.txt 2>&1 > ./reduced.txt)"
#	echo $OUT1
	if [[ ! -z $OUT1 ]]
	then
		exit
	fi
	OUT=$( { ./JSEditTester -g -s -i ./input.txt reduced.txt; } 2>&1 )
	if [[ -z $OUT ]]
	then
		let "COUNT = $COUNT + 1"
		continue
	fi
	cp ./reduced.txt ./commandsY.txt
done
cp ./reduced.txt ./commandsY.txt
