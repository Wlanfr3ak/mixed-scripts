#!/bin/bash
#Iperf3 kram
datetime=$(date %F-%H-%M)
./makespeedtest.sh | tee $datetime.txt
