#!/bin/bash
COUNT=1000
while [ $COUNT -ne 0 ]; do
	let "COUNT = $COUNT - 1"
	./JSEditFuzzy -s $COUNT > ./commandsX.txt
	OUT=$( { ./JSEditTester -g -s -i ./input.txt commandsX.txt; } 2>&1 )
	if [[ ! -z $OUT ]]
	then
		echo "ERROR"
		exit
	fi
	echo $COUNT
done
