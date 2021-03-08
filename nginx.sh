#!/bin/bash

hash -r

if [[ "$2" == "" ]]; then
  echo "usage: nginx.sh /path/to/refresh/folder fully.qualified.domain.name"
  echo ""
  echo "Note: the refresh folder should be in an area which is writeable"
  echo "      as it is used to store and refresh the letsencrypt keys"
  echo ""
  exit
fi

sudo apt-get update
sudo apt-get install -y nginx letsencrypt
sudo rm -f /etc/nginx/sites-enabled/default

sudo mkdir -p $1/var/www/$2
sudo mkdir -p $1/var/log/nginx
sudo /usr/bin/bash -c "cat site.cfg | sed -e 's*RWROOT*$1*g' | sed -e s/HOSTNAME/$2/g > /etc/nginx/sites-enabled/$2"
sudo /usr/bin/bash -c "cat index.html | sed -e s/HOSTNAME/$2/g > $1/var/www/$2/index.html"

sudo systemctl start nginx
sudo systemctl reload nginx

echo ""
echo "Forward port 80 on your firewall to this server's port 80"
echo "Forward port 443 on your firewall to this server's port 443"
echo ""
echo "Press ENTER when complete"
read ENTER

echo ""
echo "Point a web browser at http://$2/"
echo "And ensure you see: 'Browsing access to $2 is denied'."
echo ""
echo "When successfully working, press ENTER"
read ENTER

echo ""
echo "Installing LetsEncrypt"
echo ""

sudo /bin/rm -rf /etc/letsencrypt
sudo /bin/rm -rf $1/etc/letsencrypt
sudo mkdir -p $1/etc/letsencrypt
sudo ln -s $1/etc/letsencrypt /etc/letsencrypt
sudo letsencrypt certonly -a webroot --webroot-path=$1/var/www/$2 -d $2

echo ""
echo "Point a web browser at https://$2/ (note https)"
echo "And ensure you see: 'Browsing access to $2 is denied'."
echo ""
echo "When successfully working, press ENTER"
read ENTER

echo ""
echo "Remove firewall port 80 forwarding and Press ENTER when complete"
read ENTER

echo ""
echo "That's it, letsencrypt and nginx are now installed and configured"
echo ""

