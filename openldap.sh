#!/bin/bash

#--- install openldap packages ---
slapd is our openldap server and will need to be configured after install
apt-get install -y slapd ldap-utils

dpkg-reconfigure slapd
#
#Default configs
# Omit OpenLDAP server configuration - NO
# DNS Name - Leave as default
# Org Name - Leave as default
# Admin Password - Dont forget it
# Database backend - MDB
# Remove database on Purge - No
# Move old database - Yes
# Allow LDAPv2 Protocol - No


#--- ufw HIPS configuration ---
#Since we are within GCP we could let the GCP firewalls handle this
#but this is good practice when you do not have peer host trust or 
#other firewalls acting on the network
ufw allow ssh
ufw allow ldap
ufw allow ldaps
ufw allow http
ufw allow https

ufw enable




#--- install phpldapadmin web gui tool ---
#Its outdated, but does the trick

apt-get install -y phpldapadmin

#echo "Use the following for the phpldapadmin configs:"
domain=$(hostname -d | awk -F '.' '{print "dc="$1",dc="$2",dc="$3}')
hostname=$(hostname)

hostline="\$servers->setValue('server','host','$hostname');"
baseline="\$servers->setValue('server','base',array('$domain'));"
bindline="\$servers->setValue('login','bind_id','cn=admin,$domain');"
alertline="\$config->custom->appearance['hide_template_warning'] = true;"
configfile="/etc/phpldapadmin/config.php"

sed -i "293s/.*/$hostline/" $configfile 
sed -i "300s/.*/$baseline/" $configfile 
sed -i "326s/.*/$bindline/" $configfile 

echo $alertline >> $configfile

service apache2 restart
