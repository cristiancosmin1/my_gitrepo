#! /bin/bash
vi users.txt
counter=0
while read line; do
user_name=$(echo $line | awk {'print $NF}')
full_name=${line/$user_name/}
useradd -c "$full_name" $user_name
echo "$user_name:$user_name" | chpasswd
passwd -e $user_name
usermod -aG wheel "$user_name"
let "counter++"
done < users.txt
clear
cat /etc/passwd | tail -"$counter"
rm -f users.txt
