#!/bin/bash
COUNT=0
BASE=$(cat tests/settings.properties | grep baseURL)
URL="${BASE:8}"
BASE="http://$URL/dummy"
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
        #create settings.properties for each run
        cp ./tests/settings.properties ./tests/websocket.properties
        #remove props
        sed -i /apiURL/d ./tests/websocket.properties
        sed -i /apiNoView/d ./tests/websocket.properties
        sed -i /apiCodeBase/d ./tests/websocket.properties
        sed -i /apiType/d ./tests/websocket.properties
        #set props
        echo "apiURL=$URL:8000" >> ./tests/websocket.properties
        echo "apiNoView=1" >> ./tests/websocket.properties
        echo "apiCodeBase=ws/data" >> ./tests/websocket.properties
        echo "apiType=1" >> ./tests/websocket.properties

python ./websocket_bridge.py "wss://$URL" 8000 &
./testrunner.sh -r -j -a -sTests -f./results -Gpropfile=websocket.properties -t./tests/global.settings.xml ./tests/appudo.xml

