#!/bin/bash
# Based on: https://github.com/holzmaster/node-pr0gramm-miner
# With Code from: http://linuxbsdos.com/2017/06/26/how-to-install-node-js-lts-on-debian-9-stretch/
# 
# Howto:
# Use "chmod +x pr0miner-setup-debian9.sh" to make it executable and start it with "./pr0miner-setup-debian9.sh"
# After the Start the Script directly starts mining
apt-get update
apt-get upgrade
apt-get dist-upgrade
apt-get install -y  htop curl sudo git
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
sudo apt install nodejs
node --version
git clone https://github.com/holzmaster/node-pr0gramm-miner
cd node-pr0gramm-miner
npm i

##
# Add your personal Data here, you can find it under: https://pr0gramm.com/api/user/minerauth
# 
./miner.js -u <pr0username> -t <tokenid> -j <threadanzahl> -a -v
