! /bin/bash
clear
i=0
function number() {
monitoring=("ASE" "NaCl" "BSA" "Flexera")
echo "Installing ${monitoring[$i]}, 1=yes && anythin else=no"
read -n 1 -p "input : " value
echo -e
let "i++"
return $value
}
 
function Monitoring() {
yum install libnsl
for k in {1..4};do
cd /root/ToolsInstall
number
local res=$?
case $k in
1) if [ $res -eq 1 ]; then
   yum install --nogpgcheck ase-1.8.2.x86_64.rpm -y
   fi ;;
2) if [ $res -eq 1 ]; then
   yum install --nogpgcheck atos-cmf-client-nacl-3.0.3.25-8.80.x86_64.rpm -y
   if grep ^nagios /etc/passwd; then
    echo "User Nagios exist"
   else
   useradd nagios
   fi
   echo -e “nagios” >> /util/Adminsn.batch/localusers
   sudo -u nagios /home/nagios/NaCl/NaCl -s 10.109.66.13
   fi ;;
3) if [ $res -eq 1 ]; then
   ./RSCD222-LIN64.sh -silent
   echo -e "SAFRAN_L3AdminL:*     rw,map=root" >> /etc/rsc/users.local
   sed -i '/rw/s/^#//g' /etc/rsc/exports
   fi ;;
4) if [ $res -eq 1 ]; then
   cd One_package_for_unix && ./flexia-setup.sh
   fi ;;
esac
echo -e
done
}
 
Monitoring
rpm -qa | egrep -iw "ase|nacl|managesoft"