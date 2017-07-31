#!/bin/bash
# clone all http test scripts and concat them with the websocket data
declare -a tests=('account' 'async' 'fileitem' 'httpclient' 'user' 'sqlqry' 'settings');
rm tests/ws -R
mkdir tests/ws
mkdir tests/ws/data
for i in "${tests[@]}"
do
    cp -R ./tests/data/$i ./tests/ws/data/
    cat ./tests/data/websocket.swift >> ./tests/ws/data/$i/code.swift
done
./xdelta.sh
