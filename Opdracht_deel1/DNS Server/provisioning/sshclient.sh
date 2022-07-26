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
VAGRANT_LOCATION="/home/vagrant"
NETWORKCONFIGFILE="/etc/sysconfig/network-scripts/ifcfg-eth1"


#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# "Network"
#------------------------------------------------------------------------------

sed -i -e "s/NETMASK=255.255.255.240/NETMASK=255.255.255.240\nGATEWAY=172.16.128.49/" ${NETWORKCONFIGFILE}

#------------------------------------------------------------------------------
# "SSH"
#------------------------------------------------------------------------------


# generate + copy ssh key to morpheus
log "installing expect"
dnf install -y expect

log "generating ssh key"
su vagrant -c 'echo -e "\n\n\n" | ssh-keygen -t rsa -b 2048'

log "ssh-copy-id Morpheus"
cp $PROVISIONING_FILES/sshMorpheus.exp $VAGRANT_LOCATION/
chmod +x $VAGRANT_LOCATION/sshMorpheus.exp
sed -i -e 's/\r$//' $VAGRANT_LOCATION/sshMorpheus.exp
$VAGRANT_LOCATION/sshMorpheus.exp

log "ssh-copy-id Trinity"
cp $PROVISIONING_FILES/sshTrinity.exp $VAGRANT_LOCATION/
chmod +x $VAGRANT_LOCATION/sshTrinity.exp
sed -i -e 's/\r$//' $VAGRANT_LOCATION/sshTrinity.exp
$VAGRANT_LOCATION/sshTrinity.exp

# cat .ssh/authorized_keys

#------------------------------------------------------------------------------
# "DNS-server veranderen"
#------------------------------------------------------------------------------

log "DNS server aanpassen"
sed -i -e "s/nameserver.*/nameserver 172.16.128.51/" ${DNSSERVERFILE}
sed -i -e "s/search.*/search thematrix.local/" ${DNSSERVERFILE}