#!/bin/bash
# ASCI Art
# brew install toilet libcaca wget iperf3
echo "---------------------------------------------------------------"
toilet Speedtest
ip=$(wget http://checkip.dyndns.org/ -q -O - | grep -Eo '\<[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){3}\>')
datetime=$(date +"%Y-%m-%d-%H-%M")
line=$(echo "---------------------------------------------------------------")

echo $line
echo "Start at: $datetime with external IP: $ip"
echo $line
echo

echo "TCP Upload Start"
iperf3 -c dein-wlan-test.de -p 9000 -V --get-server-output # TCP Upload
echo
echo $line
echo
echo "TCP Upload End"
echo
echo $line
echo $line
echo

echo "TCP Download Start"
iperf3 -c dein-wlan-test.de -p 9000 -R -V --get-server-output # TCP Download
echo
echo $line
echo
echo "TCP Download End"
echo
echo $line
echo $line
echo

echo "TCP Upload Start with 1G"
iperf3 -b1G -c dein-wlan-test.de -p 9000 -V --get-server-output # TCP Upload with 1G Stream
echo
echo $line
echo
echo "TCP Upload End with 1G"
echo
echo $line
echo $line
echo

echo "TCP Download Start with 1G"
iperf3 -b1G -c dein-wlan-test.de -p 9000 -R -V --get-server-output # TCP Download with 1G Stream
echo
echo $line
echo
echo "TCP Download End with 1G"
echo
echo $line
echo $line
echo

echo "UDP Upload Start with 100m"
iperf3 -u -b100M -c dein-wlan-test.de -p 9000 -V --get-server-output # UDP Upload
echo
echo $line
echo
echo "UDP Upload End with100m"
echo
echo $line
echo $line
echo

echo "UDP Upload Start with 100m"
iperf3 -u -b100M -c dein-wlan-test.de -p 9000 -V --get-server-output # UDP Download
echo
echo $line
echo
echo "UDP Upload End with 100m"
echo
echo $line
echo $line
echo


echo "UDP Upload Start with 1G"
iperf3 -u -b1G -c dein-wlan-test.de -p 9000 -V --get-server-output # UDP Upload with 1G Stream
echo
echo $line
echo
echo "UDP Upload End with 1G"
echo
echo $line
echo $line
echo

echo "UDP Download Start with 1G"
iperf3 -u -b1G -c dein-wlan-test.de -p 9000 -R -V --get-server-output # UDP Download with 1G Stream
echo
echo $line
echo
echo "UDP Download End with 1G"
echo
echo $line
echo $line
echo

echo "Start with wget 1G file"
#wget aray with 
wget -O /dev/null http://speedtest.belwue.net/1G 2>&1 | tee -a $datetime.wget_log.txt
#wget -O /dev/null http://speedtest.belwue.net/10G
echo "Stop with wget 1G file"
echo
echo $line
echo $line
echo
echo
echo $line
echo $line
toilet finish!
echo $line
echo "$datetime Test finish"
echo $line
echo $line
