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
USERNAME="John"
DOMAINNAME="thematrix.local"
database="opslag"
passwd="jarnegilles123"
#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# "Clean Installation"
#------------------------------------------------------------------------------
sudo dnf clean all
sudo dnf -y update
sudo dnf install -y epel-release


sudo dnf install -y httpd httpd-tools
sudo systemctl enable --now httpd
#------------------------------------------------------------------------------
# "firewall"
#------------------------------------------------------------------------------

log "Adjusting Firewall Rules"
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

#------------------------------------------------------------------------------
# "Maria db"
#------------------------------------------------------------------------------
#?installatie maria db
sudo dnf install -y mariadb-server mariadb
sudo systemctl enable --now mariadb mariadb.service
#?passwoord is wel nog leeg maar we kunnen dit later nog aanpassen met var pwd
printf "\nn\nn\nY\nY\nY\nY\n" | sudo mysql_secure_installation
#? database configuration
log "Database config"
echo "mysql -u root -p"
echo ""
echo "use mysql"
echo "create database ${database};"  | mysql
echo "CREATE USER '${USERNAME}'@'localhost' IDENTIFIED BY '${passwd}';" | mysql
echo "GRANT ALL PRIVILEGES ON ${database}.* TO '${USERNAME}'@'localhost' IDENTIFIED BY '${passwd}' WITH GRANT OPTION;"| mysql
echo "ALTER DATABASE ${database} charset=utf8;"| mysql
echo "FLUSH PRIVILEGES;" | mysql


#------------------------------------------------------------------------------
# "PHP en Drupal"
#------------------------------------------------------------------------------

log "installing php"
sudo dnf install -y php php-mysqlnd php-dom php-simplexml php-xml php-curl php-exif php-ftp php-gd php-iconv php-json php-mbstring php-posix

#?system restarten zodat de webserver weet dat hij via php moet werken
sudo systemctl restart httpd

cd /var/www/html/
sudo wget https://ftp.drupal.org/files/projects/drupal-8.2.6.tar.gz
log "drupal uitpakken"
sudo tar -xzf drupal-8.2.6.tar.gz
log "drupal uitgepakt"
mkdir -p /var/www/html/drupal
sudo mv drupal-8.2.6/* /var/www/html/drupal
#?Dit moet 777 zijn anders lukt de installatie niet, dit moet na de config van de website best nog eens veranderd worden

cp /var/www/html/drupal/sites/default/default.settings.php /var/www/html/drupal/sites/default/settings.php
touch /etc/httpd/conf.d/drupal.conf
echo '
        <VirtualHost *:80>
            ServerName thematrix.local
            ServerAlias www.thematrix.local
            ServerAdmin admin@thematrix.local
            DocumentRoot /var/www/html/drupal/

            <Directory /var/www/html/drupal>
                    Options Indexes FollowSymLinks
                    AllowOverride All
                    Require all granted
                    RewriteEngine on
                    RewriteBase /
                    RewriteCond %{REQUEST_FILENAME} !-f
                    RewriteCond %{REQUEST_FILENAME} !-d
                    RewriteRule ^(.*)$ index.php?q=$1 [L,QSA]
            </Directory>
        </VirtualHost>' > /etc/httpd/conf.d/drupal.conf
chmod -R 777 /var/www/html/*
chown -R apache:apache /var/www/html/drupal

sudo systemctl restart httpd
sudo systemctl enable httpd