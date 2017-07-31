#!/bin/bash
set -e
DIR=$(realpath .)
$(sudo virsh net-start default &> /dev/null || true)
$(sudo virsh destroy appudo &> /dev/null || true)
cd ../appudo_package
./package.sh
./build.sh
cd $DIR
$(sudo virsh start appudo &> /dev/null || true)
./test.sh
