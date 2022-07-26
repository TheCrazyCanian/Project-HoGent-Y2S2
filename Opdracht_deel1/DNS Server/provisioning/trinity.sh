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
USERNAME="drupal"
DOMAINNAME="thematrix.local"
PASSWORD="Admin2022"
SSHFILE="/etc/ssh/sshd_config"
NETWORKCONFIGFILE="/etc/sysconfig/network-scripts/ifcfg-eth1"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# "Installatie modules"
#------------------------------------------------------------------------------

log "Installing modules"
dnf module enable -y postgresql:13
dnf module enable -y nginx:1.16
dnf module enable -y php:7.3
dnf install -y postgresql-server nginx @php php php-{cli,mysqlnd,json,opcache,xml,mbstring,gd,curl,pgsql}

#------------------------------------------------------------------------------
# "SSH"
#------------------------------------------------------------------------------

#zorgt ervoor dat root en gewone gebruikers niet meer via paswoord via ssh kunnen inloggen
log "ssh config file aanpassen"
sed -i "s/PermitRootLogin.*/PermitRootLogin no/" ${SSHFILE}
sed -i "s/PasswordAuthentication.*/PasswordAuthentication no/" ${SSHFILE}
chmod 600 .ssh/authorized_keys
chmod 700 .ssh
# in principe zou ssh moeten herstart worden, maar dan kan je met de sshclient niet meer ssh'en in de VM. 
# De ssh restart gebeurt dus via de sshclient.

#------------------------------------------------------------------------------
# "configuratie Posgresql"
#------------------------------------------------------------------------------

log "Creating a New PostgreSQL Database Cluster"
postgresql-setup --initdb
systemctl enable --now postgresql

log "Role, database en gebruiker aanmaken"
sudo -u postgres createuser -s ${USERNAME}                                   # -s = superuser, -w no password
sudo -u postgres createdb ${USERNAME} -O ${USERNAME}                         # for any role used to log in, that role will have a database with the same name which it can access, -O = owner
sudo -u postgres psql -c "alter user ${USERNAME} with password '${PASSWORD}';"
useradd -m -p $(echo ${PASSWORD} | openssl passwd -1 -stdin) -s /bin/bash ${USERNAME} 


# sudo -i -u postgres -> -i = login, -u = user -> inloggen als standaard postgres gebruiker
# psql -> in de postgresql prompt gaan


#------------------------------------------------------------------------------
# "Configuratie NGINX"
#------------------------------------------------------------------------------

log "Enabling nginx"
systemctl enable --now nginx

log "Adjusting Firewall Rules"
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

log "Setting Up Server Blocks"
sudo mkdir -p /var/www/${DOMAINNAME}/html
# sudo chown -R $USER:$USER /var/www/${DOMAINNAME}/html
# sudo cp -r /usr/share/nginx/html/* /var/www/${DOMAINNAME}/html/

echo 'server {
    listen 80;
    listen [::]:80;
    server_name '${DOMAINNAME}' www.'${DOMAINNAME}';
    return 301 https://$host$request_uri;
}

server {
        listen 443 http2 ssl;
        listen [::]:443 http2 ssl;
        server_name '${DOMAINNAME}' www.'${DOMAINNAME}';
        root /var/www/'${DOMAINNAME}'/html/drupal;
        server_tokens off;
        
        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
        ssl_dhparam /etc/ssl/certs/dhparam.pem;
        
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers ECDH+AESGCM:ECDH+AES256-CBC:ECDH+AES128-CBC:DH+3DES:!ADH:!AECDH:!MD5;
        ssl_ecdh_curve secp384r1;
        ssl_session_cache shared:SSL:10m;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;      

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Very rarely should these ever be accessed outside of your lan
    location ~* \.(txt|log)$ {
        allow 192.168.0.0/16;
        deny all;
    }

    location ~ \..*/.*\.php$ {
        return 403;
    }

    location ~ ^/sites/.*/private/ {
        return 403;
    }

    # Block access to scripts in site files directory
    location ~ ^/sites/[^/]+/files/.*\.php$ {
        deny all;
    }

    # Allow "Well-Known URIs" as per RFC 5785
    location ~* ^/.well-known/ {
        allow all;
    }

    # Block access to "hidden" files and directories whose names begin with a
    # period. This includes directories used by version control systems such
    # as Subversion or Git to store control files.
    location ~ (^|/)\. {
        return 403;
    }

    location / {
        # try_files $uri @rewrite; # For Drupal <= 6
        try_files $uri /index.php?$query_string; # For Drupal >= 7
    }

    location @rewrite {
        #rewrite ^/(.*)$ /index.php?q=$1; # For Drupal <= 6
        rewrite ^ /index.php; # For Drupal >= 7
    }

    # Dont allow direct access to PHP files in the vendor directory.
    location ~ /vendor/.*\.php$ {
        deny all;
        return 404;
    }

    # Protect files and directories from prying eyes.
    location ~* \.(engine|inc|install|make|module|profile|po|sh|.*sql|theme|twig|tpl(\.php)?|xtmpl|yml)(~|\.sw[op]|\.bak|\.orig|\.save)?$|^(\.(?!well-known).*|Entries.*|Repository|Root|Tag|Template|composer\.(json|lock)|web\.config)$|^#.*#$|\.php(~|\.sw[op]|\.bak|\.orig|\.save)$ {
        deny all;
        return 404;
    }

    # In Drupal 8, we must also match new paths where the '.php' appears in
    # the middle, such as update.php/selection. The rule we use is strict,
    # and only allows this pattern with the update.php front controller.
    # This allows legacy path aliases in the form of
    # blog/index.php/legacy-path to continue to route to Drupal nodes. If
    # you do not have any paths like that, then you might prefer to use a
    # laxer rule, such as:
    #   location ~ \.php(/|$) {
    # The laxer rule will continue to work if Drupal uses this new URL
    # pattern with front controllers other than update.php in a future
    # release.
    location ~ "\.php$|^/update.php" {
        fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
        # Ensure the php file exists. Mitigates CVE-2019-11043
        try_files $fastcgi_script_name =404;
        # Security note: If youre running a version of PHP older than the
        # latest 5.3, you should have "cgi.fix_pathinfo = 0;" in php.ini.
        # See http://serverfault.com/q/627903/94922 for details.
        include fastcgi_params;
        # Block httpoxy attacks. See https://httpoxy.org/.
        fastcgi_param HTTP_PROXY "";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param QUERY_STRING $query_string;
        fastcgi_intercept_errors on;
        # PHP 5 socket location.
        #fastcgi_pass unix:/var/run/php5-fpm.sock;
        # PHP 7 socket location.
        fastcgi_pass unix:/run/php-fpm/www.sock;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        try_files $uri @rewrite;
        expires max;
        log_not_found off;
    }

    # Fighting with Styles? This little gem is amazing.
    # location ~ ^/sites/.*/files/imagecache/ { # For Drupal <= 6
    location ~ ^/sites/.*/files/styles/ { # For Drupal >= 7
        try_files $uri @rewrite;
    }

    # Handle private files through Drupal. Private files path can come
    # with a language prefix.
    location ~ ^(/[a-z\-]+)?/system/files/ { # For Drupal >= 7
        try_files $uri /index.php?$query_string;
    }

    # Enforce clean URLs
    # Removes index.php from urls like www.example.com/index.php/my-page --> www.example.com/my-page
    # Could be done with 301 for permanent or other redirect codes.
    if ($request_uri ~* "^(.*/)index\.php/(.*)") {
        return 307 $1$2;
    }
}
' > /etc/nginx/conf.d/"${DOMAINNAME}.conf"

log "Creating certificates"

sudo mkdir /etc/ssl/private
sudo chmod 700 /etc/ssl/private
printf "BE\nOost-Vlaanderen\nGent\nHogent\nGent\nthematrix.local\nwebmaster@example.com\n" | sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

sudo systemctl restart nginx

# to test: ip a
# to check certificate: openssl x509 -in /etc/ssl/certs/nginx-selfsigned.crt -text -noout
# check downloadable nginx versions: dnf module list nginx
# check config syntax: nginx -t
# curl -4 icanhazip.com

#------------------------------------------------------------------------------
# Config Drupal and php
#------------------------------------------------------------------------------
log "Enable php"
sudo systemctl enable --now php-fpm

log "Install Drupal"
wget https://ftp.drupal.org/files/projects/drupal-9.2.16.tar.gz
tar -xzf drupal-9.2.16.tar.gz
mv drupal-9.2.16 /var/www/${DOMAINNAME}/html/drupal
sudo mkdir /var/www/${DOMAINNAME}/html/drupal/sites/default/files
sudo cp /var/www/${DOMAINNAME}/html/drupal/sites/default/default.settings.php /var/www/${DOMAINNAME}/html/drupal/sites/default/settings.php

# cat $PROVISIONING_FILES/phpfile.txt > /etc/php-fpm.d/drupal.conf

log "postgresql authentification configuration aanpassen"
sed -i 's|host    all             all             127.0.0.1/32            ident|host    all             all             127.0.0.1/32            md5|' /var/lib/pgsql/data/pg_hba.conf
sed -i 's|host    all             all             ::1/128                 ident|host    all             all             ::1/128                 md5|' /var/lib/pgsql/data/pg_hba.conf

log "permissies aanpassen"
chmod 777 -R /var/www/${DOMAINNAME}/html/drupal/

log "SELinux aanpassen"
sudo restorecon -R /var/www/
sudo chown -R $USERNAME:$USERNAME /var/www/${DOMAINNAME}/html/drupal
sudo setsebool -P httpd_can_network_connect_db on
sudo setsebool -P httpd_unified 1

log "services restarten"
systemctl restart php-fpm
systemctl restart postgresql
systemctl restart nginx

# sudo grep denied /var/log/audit/audit.log
# sudo dnf -y install setroubleshoot-server setools-console
# sealert -a /var/log/audit/audit.log

#------------------------------------------------------------------------------
# "DNS-server veranderen"s
#------------------------------------------------------------------------------

log "DNS server aanpassen"
sed -i -e "s/nameserver.*/nameserver 172.16.128.51/" ${DNSSERVERFILE}
sed -i -e "s/search.*/search thematrix.local/" ${DNSSERVERFILE}

#------------------------------------------------------------------------------
# "Network"
#------------------------------------------------------------------------------

sed -i -e "s/NETMASK=255.255.255.240/NETMASK=255.255.255.240\nGATEWAY=172.16.128.49/" ${NETWORKCONFIGFILE}
ifdown eth1 
ifup eth1
ifdown eth0