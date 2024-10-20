#! /bin/bash

localectl set-locale LANG=en_US.utf8

clear

echo 'Install SAE Virtual server rhel8.6'
echo '1=contine,2=exit'
read -n 1 -p "input : " answare
clear

RUG() {
echo ' RUG install(yes) , anything else(no)'
number
local res=$?
clear

if [ $res -eq 1 ]; then
 index=-1
  while (( $index <= 3 )); do
   let "index++"
    case $index in
        1)
        echo "
        Act in the RUG, by accessing this URL (tested with Firefox) from L2_SAE, using SAE credentials:
        https://rug.snm.snecma/cgi/Adminsn.cgi

        Toolstab->Atos tools-> "Create a server account"

        Hostname = hostname of the server.
        Libelle/Description = usual name of the server as per intake form."
         ;;
        2)
        echo -e "\n"
        echo "
        Install RUG, press ENTER if the prompt does not return automatically after the install"
          cd /root/ToolsInstall && bash install
          /AXIS/appl/DIVERS/LDAP/REDHAT/Auto_KRB_RedHat8.sh
         ;;
        3)
        echo
        grep ldap /etc/nsswitch.conf && sleep 3
        systemctl status winbind
        clear
        echo "Modify /etc/sudoers"
        pause
        vi /etc/sudoers
        clear
       esac
   done
else
 break
fi

}

function pause() {
read -s -n1 -p "Press any key to continue ..."
echo ""
}

osConfiguration() {
clear
echo "Press 1 to continue with the configuration "
read -n 1 -p "input : " variable

local counter=0
array=("/etc/sysconfig/network-scripts/ifcfg-ens192" "/etc/fstab" "/etc/hosts" "/etc/resolv.conf" "/etc/chrony.conf")
for i in ${array[@]}; do
        echo -e "\n"
        let "counter++"
        if [ $counter -eq 1 ]; then
         echo "Modify the network interface..."
         pause
         vi $i
        elif [ $counter -eq 2 ]; then
         echo "Modify fstab..."
         pause
         vi $i
        elif [ $counter -eq 3 ]; then
         echo "Modify hosts..."
         pause
         vi $i
        elif [ $counter -eq 4 ]; then
         echo "Modify DNS..."
         pause
         vi $i
        elif [ $counter -eq 5 ]; then
         echo "Modify chrony..."
         pause
         vi $i
         echo -e "\n"
         systemctl enable chronyd.service && systemctl start chronyd.service
         echo -e "\n"
        else
         echo "Now register the machine to satellite..."
         pause
        fi

done

}

essentials() {

yum clean all
yum repolist
yum update yum
yum update
clear
cp -p /root/ToolsInstall/banner-linux_2019.ksh /util
echo "Type banner's  SERVICE OFFERING"
pause
read -p 'Service name: ' serviceName
sed -i.orig_conf -r 's/usual-name_environment/$serviceName/g' /util/banner-linux_2019.ksh && cat /util/banner-linux_2019.ksh
cp -p /root/ToolsInstall/magicsar /etc/init.d/ && cp /AXIS/appl/DIVERS/Magic_sar/MAGIC_SAR.tar /util && cd /util && tar xvf MAGIC_SAR.tar
rm MAGIC_SAR.tar
chkconfig --add magicsar && chkconfig magicsar on && service magicsar start && ps -ef | grep magic
cp -p /root/ToolsInstall/snecma /etc/init.d/ && chkconfig --add snecma && chkconfig snecma on
cp -avr /root/ToolsInstall/systeme /util && cp -avr /root/ToolsInstall/pilotage /util && /AXIS/ADMINSRV/tmpproc/LinuxMAINSH.ksh
systemctl stop firewalld.service && systemctl disable firewalld.service
cd /root/ToolsInstall && yum install --nogpgcheck figlet-2.2.5-18.20151018gita565ae1.el8.x86_64.rpm
clear

}

function number() {
read -n 1 -p " input : " value
echo ""
return $value
}

osConfiguration2() {
clear
echo -e "\n Install NMON, modify crontab and history, 1(yes) or anything else(no) "
number
local res=$?

if [ $res -eq 1 ]; then
mkdir /util/nmon
cp -p /root/ToolsInstall/nmon-16m-1.el8.x86_64.rpm /tmp && cd /tmp
rpm -Uvh nmon-16m-1.el8.x86_64.rpm

echo -e "\n# NMON default display \nexport NMON=mndc" >> /root/.bashrc
echo -e "\n# Date and time in history \nexport HISTTIMEFORMAT='%F %T '" >> /root/.bash_profile
clear
echo "Modify crontab"
pause
crontab -e
clear
echo "Modify /etc/cron.d/sysstatvi"
clear
pause
vi /etc/cron.d/sysstatvi
fi

clear
}

RedHatSatellite() {

curl -O http://s11280k0/pub/bootstrap.py
chmod +x bootstrap.py

echo -e "\n"
echo "To register the machine in RH Satellite, complete: "
echo -e "\n"
read -p 'Type the environment: ' env
read -p 'Type the VLAN: ' vlan
read -p 'Type the Sattelite ID: ' id

echo -e "\n"

/usr/libexec/platform-python bootstrap.py --login=$id --server s11280k0.snm.snecma --location='Worldwide' --organization='Safran Aircraft Engines' --hostgroup='Linux-VM/$(env^^}/VLAN$vlan/RHEL8' --activationkey="RHEL8.6" --force --install-katello-agent

clear

}

monitoring() {
for i in {1..4}
do
                case $i in
                1)
                 echo -e "\n Install ASE, 1(yes) anything else(no) ?"
                 number
                 local res=$?
                 if [ $res -eq 1 ]
                 then
                    yum install --nogpgcheck ase-1.8.2.x86_64.rpm
                 else
                  continue
                 fi
                ;;
                2)
                 echo -e "\n Install BSA, 1(yes) or anything else(no) ?"
                  number
                  local res=$?
                  if [ $res -eq 1 ]
                  then
                   cd /root/ToolsInstall && ./RSCD222-LIN64.sh -silent
                   clear
                   echo -e 'SAFRAN_L3AdminL:*     rw,map=root' >> /etc/rsc/users.local
                   bash RSCD222-LIN64.sh -silent
                   vi /etc/rsc/users
                  else
                   continue
                  fi
                 ;;
                3)
                  echo -e "\n Install Nagios, 1(yes) anything else(no) ?"
                   number
                   local res=$?
                  if [ $res -eq 1 ]
                  then
                    echo -e "\n"
                    array=( 128.38.11.149 10.57.234.22 10.248.6.15 10.57.234.18 10.57.66.17 10.57.234.13 10.57.234.19 10.109.234.13 10.109.234.19 10.109.234.16 10.109.66.13 )
                    array=( $(shuf -e "${array[@]}") )
                        for i in "${array[@]}"; do
                        echo -e '\035\nquit' | timeout 2 telnet $i 443 &> /dev/null;
                        if [ $? -eq 0 ]; then
                        echo "$i is good"
                         break
                        else
                        echo "no telnet on $i"
                        fi
                        done
                    echo -e "\n"
                    yum install --nogpgcheck atos-cmf-client-nacl-3.0.3.25-8.80.x86_64.rpm
                    su - nagios
                    echo -e nagios >> /util/Adminsn.batch/localusers
                  else
                   continue
                 fi
                 ;;
                4)
                 echo -e "\n Install Flexera, 1(yes) or anything else(no)?"
                  number
                  local res=$?
                 if [ $res -eq 1 ]
                 then
                  cd /root/ToolsInstall/One_package_for_unix && chmod +x flexia-setup.sh
                  bash flexia-setup.sh
                 else
                  break
                 fi
                 ;;
                esac
done
clear && sleep 5

}

infoExcel() {
clear
echo "Hostname is :" $HOSTNAME
echo "Hostnmae IP :" $(hostname -I)
echo "SAE Backup Server : " s11648k0
echo "Number of CPU's : " lscpu |  sed -n '4p' | awk '{print $2}'
echo "Firmware Name : "  $(dmidecode -s bios-vendor)
echo "Firmware Version : " $(dmidecode -s bios-version)
echo "MAC adress : " $(ifconfig | sed -n '3p' | awk '{print $2}')
echo "Operating System : " cat /etc/os-release | sed -n '2p'
echo "OS Version : " $(uname -r)
echo "RAM : " $(free -m | sed -n '2p' | awk '{print $2}')
dmidecode -t1 | sed -n '10p' | xargs
echo -e '\n'

rpm -qa |egrep -iw "ase|nacl|managesoft"

}


if [ $answare -eq 1 ]
then
                osConfiguration
                RedHatSatellite
                essentials
                RUG
                osConfiguration2
                monitoring
                infoExcel
else
                echo 'end'

fi

