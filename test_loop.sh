#!/bin/bash
while true; do
        STOP=$(cat stop.txt)
        if[ $STOP -eq 1]; then
                break
        fi
        ./test.sh
done
