#! /bin/bash


if grep ^dt997988 /etc/passwd; then
        echo "Users exist"
else

useradd dt997988 -c "EOC account-Robin Claudon"
echo "dt997988:Bridgemonitoring789+" | chpasswd

useradd atosn1eoc -c "EOC account"
echo "atosn1eoc:Bridgemonitoring789+" | chpasswd

chage -m 0 -M 99999 -I -1 -E -1 dt997988
chage -m 0 -M 99999 -I -1 -E -1 atosn1eoc

cp /etc/sudoers /etc/sudoers.backupeoc

if [ $(getent group sfi_exploit) ]; then
        usermod -aG sfi_exploit dt997988
        usermod -aG sfi_exploit atosn1eoc
else
        echo "Group does not exist "
fi

if grep -q -i "release 6" /etc/redhat-release
then
cp /etc/sudoers /etc/sudoers.backupeoc
echo "dt997988 ALL=(root) /opt/ASE/bin/ase stop, /opt/ASE/bin/ase start, /opt/ASE/bin/ase events, /opt/ASE/bin/ase status, /sbin/swapoff -a, /sbin/swapon -a, /sbin/logrotate -f /etc/logrotate.conf, /sbin/service ntpd status, /sbin/service ntpd start, /sbin/service ntpd stop" >> /etc/sudoers
echo "atosn1eoc ALL=(root) /opt/ASE/bin/ase stop, /opt/ASE/bin/ase start, /opt/ASE/bin/ase events, /opt/ASE/bin/ase status, /sbin/swapoff -a, /sbin/swapon -a, /sbin/logrotate -f /etc/logrotate.conf, /sbin/service ntpd status, /sbin/service ntpd start, /sbin/service ntpd stop" >> /etc/sudoers
visudo -c

else

echo "dt997988 ALL=(root) /opt/ASE/bin/ase stop, /opt/ASE/bin/ase start, /opt/ASE/bin/ase events, /opt/ASE/bin/ase status, /sbin/swapoff -a, /sbin/swapon -a, /sbin/logrotate -f /etc/logrotate.conf, /bin/systemctl status chronyd, /bin/systemctl start chronyd, /bin/systemctl stop chronyd" >> /etc/sudoers
echo "atosn1eoc ALL=(root) /opt/ASE/bin/ase stop, /opt/ASE/bin/ase start, /opt/ASE/bin/ase events, /opt/ASE/bin/ase status, /sbin/swapoff -a, /sbin/swapon -a, /sbin/logrotate -f /etc/logrotate.conf, /bin/systemctl status chronyd, /bin/systemctl start chronyd, /bin/systemctl stop chronyd" >> /etc/sudoers
visudo -c

fi

id dt997988 && id atosn1eoc

fi

