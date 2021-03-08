#!/bin/bash

hash -r

if [[ "$2" == "" ]]; then
  echo "usage: nginx.sh /writeable/path domain.name [hostname:port]"
  echo ""
  echo " /writeable/path   - Path on the current system which is"
  echo "                     guaranteed to be writeable to root"
  echo "                     This is used to store and configure"
  echo "                     letsencrypt."
  echo ""
  echo " domain.name       - Fully qualified domain name which"
  echo "                     points to the modem's public IP"
  echo "                     address."
  echo ""
  echo " hostname:port     - Optional server and port number of"
  echo "                     a http server or application to"
  echo "                     receive all requests. i.e. the"
  echo "                     https web server will be configured"
  echo "                     as a proxy."
  echo ""
  exit
fi

if [[ "$3" == "" ]]; then
  SITESFILE="site-server.cfg"
else
  SITESFILE="site-forward.cfg"
fi

sudo apt-get update
sudo apt-get install -y nginx letsencrypt
sudo rm -f /etc/nginx/sites-enabled/default

sudo mkdir -p $1/var/www/$2
sudo mkdir -p $1/var/log/nginx
sudo /usr/bin/bash -c "cat site-install.cfg | sed -e 's*RWROOT*$1*g' | sed -e s/HOSTNAME/$2/g > /etc/nginx/sites-enabled/$2"
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

sudo /usr/bin/bash -c "cat $SITESFILE | sed -e 's/RELAYPORT/$3/' | sed -e 's*RWROOT*$1*g' | sed -e s/HOSTNAME/$2/g > /etc/nginx/sites-enabled/$2"
sudo systemctl restart nginx

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

