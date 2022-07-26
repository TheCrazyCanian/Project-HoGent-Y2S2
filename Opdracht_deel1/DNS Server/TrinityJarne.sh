#! /bin/bash
#
# Provisioning script for server www

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # do not mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}files/${HOSTNAME}"

DNSSERVERFILE="/etc/resolv.conf"
password="123456"
naamDB="server"
naamgebruiker="admin"
#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# "Installatie Webserver"
#------------------------------------------------------------------------------

sudo dnf install -y epel-release
sudo dnf install -y dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf -y update
sudo dnf module -y enable php:remi-8.1
sudo dnf install -y nginx php-fpm

sudo firewall-cmd --permanent --zone=public --add-service=https --add-service=http
sudo firewall-cmd --reload

sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start php-fpm
sudo systemctl enable php-fpm

#installatie postgresql14
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql14 postgresql14-server
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl enable --now postgresql-14

#installatie drupal en config postregsql


log "gebruikers aanmaken"
useradd -m -s /bin/bash -p ${password} $naamgebruiker 
sudo -u postgres createuser --encrypted --no-createdb -w --no-password $naamgebruiker
sudo -u postgres createdb --encoding=UNICODE --owner=$naamgebruiker $naamDB

#postgresql user aanmaken voor drupal
log "gebruiker en database aangemaakt"
#sudo -u postgres psql; alter user $naamgebruiker with encrypted password $password;

#instalatie drupal
cd /var/www/html/
sudo wget https://ftp.drupal.org/files/projects/drupal-8.2.6.tar.gz
log "drupal uitpakken"
sudo tar -xzvf drupal-8.2.6.tar.gz
log "drupal uitgepakken"
mkdir -p /var/www/html/drupal
sudo mv drupal-8.2.6/* /var/www/html/drupal

mkdir /var/www/html/drupal/sites/default/files
cp /var/www/html/drupal/sites/default/default.settings.php /var/www/html/drupal/sites/default/settings.php
log "permissies geven aan nginx"
sudo chown -R nginx:nginx /var/www/html/drupal/
#user en groep nog aanpassen
log "configfile php-fpm"
cat $PROVISIONING_FILES/phpfile.txt > /etc/php-fpm.d/drupal.conf
log "configfile nginx"
cat $PROVISIONING_FILES/nginxconfig.txt > /etc/nginx/conf.d/drupal.conf
systemctl restart php-fpm
systemctl restart nginx 



#postgres toevoegen aan firewall
firewall-cmd --permanent --zone=public --add-port=5432/tcp

#------------------------------------------------------------------------------
# "DNS-server veranderen"
#------------------------------------------------------------------------------

log "DNS server aanpassen"
#sed -i -e "s/nameserver.*/nameserver 172.16.128.51/" ${DNSSERVERFILE}

