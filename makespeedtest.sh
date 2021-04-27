#!/bin/bash
iperf3 -c dein-wlan-test.de -p 9000 -V --get-server-output # TCP Upload
iperf3 -c dein-wlan-test.de -p 9000 -R -V --get-server-output # TCP Download
iperf3 -b1G -c dein-wlan-test.de -p 9000 -V --get-server-output # TCP Upload with 1G Stream
iperf3 -b1G -c dein-wlan-test.de -p 9000 -R -V --get-server-output # TCP Download with 1G Stream
iperf3 -u -c dein-wlan-test.de -p 9000 -V --get-server-output # UDP Upload
iperf3 -u -c dein-wlan-test.de -p 9000 -V --get-server-output # UDP Download
iperf3 -u -b1G -c dein-wlan-test.de -p 9000 -V --get-server-output # UDP Upload with 1G Stream
iperf3 -u -b1G -c dein-wlan-test.de -p 9000 -R -V --get-server-output # UDP Download with 1G Stream
