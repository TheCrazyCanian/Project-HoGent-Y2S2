#! /bin/bash
#
# Provisioning script for server ns

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

CONFIGFILE="/etc/named.conf"
DOMAINNAME="thematrix.local"
FWDZONE="/var/named/forward.$DOMAINNAME"
IPV4RVZONE="/var/named/reverseIPv4.$DOMAINNAME"
IPV6RVZONE="/var/named/reverseIPv6.$DOMAINNAME"
NET_INT_IPV4="172.16.128.51"
NAME="morpheus"
SSHFILE="/etc/ssh/sshd_config"
DNSSERVERFILE="/etc/resolv.conf"
NETWORKCONFIGFILE="/etc/sysconfig/network-scripts/ifcfg-eth1"

#ip adress opdelen voor reverse lookup addres
IPV4RVADD=$(echo ${NET_INT_IPV4} | awk -F "." '{ printf "%s.%s.%s", $3, $2, $1 }')
IPV6RVADD="a.0.0.0.d.a.c.a.8.b.d.0.1.0.0.2"
#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

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
# DNS reverse lookup, autorathive only name server
#------------------------------------------------------------------------------

log "installeer bind"

dnf install -y bind

log "wijzig de named.conf file"

sed -i -e "s/listen-on port.*/listen-on port 53 { any; };/" $CONFIGFILE
sed -i -e "s/listen-on-v6 port.*/listen-on-v6 port 53 { any; };/" $CONFIGFILE
sed -i -e "s/allow-query.*/allow-query { any; };/" $CONFIGFILE
sed -i -e "s/\trecursion yes;/\trecursion yes;\n\n\tforwarders {\n\t\t1.1.1.1;\n\t\t193.190.173.1;\n\t};/" $CONFIGFILE  
sed -i -e "s/dnssec-enable yes;/dnssec-enable no;/" $CONFIGFILE  
sed -i -e "s/dnssec-validation yes;/dnssec-validation no;/" $CONFIGFILE 


# Als de lengte van de named.conf niet gelijk is aan 80, dan is het nog niet aangepast en moet het dus nog aangepast worden
if [ $(sudo wc -l /etc/named.conf | cut -d" " -f1) -ne 80 ]; then
sed -i '57s/zone "." IN {/zone "'$DOMAINNAME'" IN {/' $CONFIGFILE
sed -i '58s/type hint;/type master;/' $CONFIGFILE
sed -i '59s/file "named.ca";/file "forward.'$DOMAINNAME'";\n\tnotify yes;\n\tallow-update { 172.16.128.50; };/' $CONFIGFILE
sed -i '64s/^/zone "'$IPV4RVADD'.in-addr.arpa" IN {\n\ttype master;\n\tfile "reverseIPv4.'$DOMAINNAME'";\n\tnotify yes;\n\tallow-update { 172.16.128.50; };\n};\n\nzone "'$IPV6RVADD'.ip6.arpa" IN {\n\ttype master;\n\tfile "reverseIPv6.'$DOMAINNAME'";\n\tnotify yes;\n\tallow-update { 172.16.128.50; };\n};\n\n/' $CONFIGFILE
else
log "Zones zijn al toegevoegd aan named.conf"
fi

log "zone files aanmaken"

echo '$ORIGIN '$DOMAINNAME'.
$TTL 86400

@ IN SOA '$NAME'.'$DOMAINNAME'. gilles.depraeter.student.hogent.be. (
  1646756651 1D 1H 1W 1D )

                           IN  NS     '$NAME'
                           IN  MX     10 neo



physical                   IN  A      172.16.0.1
physical                   IN  AAAA   2001:DB8:ACAD:A::6
ps                         IN  CNAME  physical
morpheus                   IN  A      172.16.128.51
morpheus                   IN  AAAA   2001:DB8:ACAD:A::2 
ns                         IN  CNAME  morpheus
agentsmith                 IN  A      172.16.128.50
agentsmith                 IN  AAAA   2001:DB8:ACAD:A::1
dc                         IN  CNAME  agentsmith
trinity                    IN  A      172.16.128.52
trinity                    IN  AAAA   2001:DB8:ACAD:A::3
www                        IN  CNAME  trinity
neo                        IN  A      172.16.128.53
neo                        IN  AAAA   2001:DB8:ACAD:A::4
imap                       IN  CNAME  neo
theoracle                  IN  A      172.16.128.54
theoracle                  IN  AAAA   2001:DB8:ACAD:A::5
mdt                        IN  CNAME  theoracle
@                          IN  A      172.16.128.52' > $FWDZONE


echo '$TTL    86400
$ORIGIN '$IPV4RVADD'.in-addr.arpa.

@       IN      SOA     morpheus.thematrix.local. gilles.depraeter.student.hogent.be.  (
    1997022700 1D 1H 1W 1D )

        IN      NS      '$NAME'.'$DOMAINNAME'.

51      IN      PTR     morpheus.'$DOMAINNAME'.
50      IN      PTR     agentsmith.'$DOMAINNAME'.
52      IN      PTR     trinity.'$DOMAINNAME'.
53      IN      PTR     neo.'$DOMAINNAME'.
54      IN      PTR     theoracle.'$DOMAINNAME'.' > $IPV4RVZONE


echo '$TTL    86400
$ORIGIN '$IPV6RVADD'.ip6.arpa.

@       IN      SOA     morpheus.thematrix.local. gilles.depraeter.student.hogent.be.  (
    1997022701 1D 1H 1W 1D )

        IN      NS      '$NAME'.'$DOMAINNAME'.

2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0      IN      PTR     morpheus.'$DOMAINNAME'.
1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0      IN      PTR     agentsmith.'$DOMAINNAME'.
3.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0      IN      PTR     trinity.'$DOMAINNAME'.
4.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0      IN      PTR     neo.'$DOMAINNAME'.
5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0      IN      PTR     theoracle.'$DOMAINNAME'.' > $IPV6RVZONE

log "adjusting firewall settings"

firewall-cmd --permanent --add-port=53/udp
firewall-cmd --permanent --add-port=53/tcp
firewall-cmd --reload

log "enable de service"

systemctl enable --now named

log "DNS server aanpassen (/etc/resolv.conf)"
sed -i -e "s/nameserver.*/nameserver 172.16.128.51/" ${DNSSERVERFILE}
sed -i -e "s/search.*/search thematrix.local/" ${DNSSERVERFILE}

#------------------------------------------------------------------------------
# "Network"
#------------------------------------------------------------------------------

sed -i -e "s/NETMASK=255.255.255.240/NETMASK=255.255.255.240\nGATEWAY=172.16.128.49/" ${NETWORKCONFIGFILE}
ifdown eth1 
ifup eth1
ifdown eth0