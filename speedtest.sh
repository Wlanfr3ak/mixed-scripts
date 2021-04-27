#!/bin/bash
#Iperf3 kram
datetime=$(date +"%Y-%m-%d-%H-%M")
./makespeedtest.sh | tee $datetime.txt
