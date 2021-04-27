#!/bin/bash
# Use the makespeedtest.sh from this repo in same folder!
datetime=$(date +"%Y-%m-%d-%H-%M")
./makespeedtest.sh | tee $datetime.txt
