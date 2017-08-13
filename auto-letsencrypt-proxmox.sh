#!/bin/bash
# based on:
# https://blog.hostonnet.com/install-letsencrypt-ssl-proxmox
# https://www.thielomat.de/lets-encrypt-ssl-zertifikat-fuer-proxmox/
# Works on Debian 9 with installed Proxmox Service
# make it executable with "chmod +x filename" and run and check/fillout the Questions at the run!

# install and initialize LetsEncrypt
cd /usr/local/sbin
wget https://dl.eff.org/certbot-auto
chmod a+x /usr/local/sbin/certbot-auto
certbot-auto --help

# enter your Domainname in the Variable
dn=$(echo "server01.domainname.tld")

# generate, validate and change the certs
certbot-auto certonly -d $dn
cp /etc/pve/local/pve-ssl.key /etc/pve/local/pve-ssl.key.orig
cp /etc/pve/local/pve-ssl.pem /etc/pve/local/pve-ssl.key.pem.orig
cd /etc/letsencrypt/live/$dn/
cp fullchain.pem /etc/pve/local/pve-ssl.pem
cp privkey.pem /etc/pve/local/pve-ssl.key
cp chain.pem /etc/pve/pve-root-ca.pem
# doesnt work leave feedback please
#pvecm updatecerts

service pveproxy restart
service pvedaemon restart

# renew script
cd /root/
cat <<EOF > ssl-renew.sh
#!/bin/bash
/usr/local/sbin/certbot-auto renew >> /var/log/le-renew.log
rm -rf /etc/pve/local/pve-ssl.pem
rm -rf /etc/pve/local/pve-ssl.key
rm -rf /etc/pve/pve-root-ca.pem
cp /etc/letsencrypt/live/$dn/fullchain.pem  /etc/pve/local/pve-ssl.pem
cp /etc/letsencrypt/live/$dn/privkey.pem /etc/pve/local/pve-ssl.key
cp /etc/letsencrypt/live/$dn/chain.pem /etc/pve/pve-root-ca.pem
# doesnt work leave feedback please
#pvecm updatecerts
service pveproxy restart
service pvedaemon restart
EOF

# make it executable and push to /etc/crontab
chmod +x ssl-renew.sh
echo "@monthly /root/ssl-renew.sh" >> /etc/crontab
