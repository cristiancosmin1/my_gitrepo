#! /bin/bash
set -x
yum install -y net-snmp net-snmp-utils net-snmp-libs net-snmp-devel
service snmpd stop
# give read-only access
net-snmp-config --create-snmpv3-user -ro  -A 03712093710 -X 08721049720938312 -a SHA -x AES ddsi4mon 

if [[ 'grep -qi "release 6" /etc/redhat-release' ]]; then
#enable snmpd
chkconfig snmpd on
else
systemctl enable snmpd
systemctl daemon-reload
fi
service snmpd start

