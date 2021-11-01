#!/bin/bash

echo ''
echo "==============================================" 
echo "Install packages...                           "
echo "=============================================="
echo ''

dnf install -y yum-utils device-mapper-persistent-data lvm2 
dnf install -y iproute-tc net-tools openssh-server perl bind-utils

echo ''
echo "==============================================" 
echo "Done: Install packages.                       "
echo "=============================================="
echo ''

# if LXD container will be running on XFS file system
# dnf install -y xfsprogs xfsprogs-devel xfsdump 

echo ''
echo "==============================================" 
echo "Enable sshd...                                "
echo "=============================================="
echo ''

systemctl enable sshd
service sshd start

echo ''
echo "==============================================" 
echo "Done: Enable sshd.                            "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Remove package runc...                        "
echo "=============================================="
echo ''

dnf remove -y runc

echo ''
echo "==============================================" 
echo "Done: Remove package runc.                    "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Set root user password ...                    "
echo "=============================================="
echo ''

usermod --password `perl -e "print crypt('root','root');"` root

sleep 5

clear

echo ''
echo "==============================================" 
echo "Done: Set root user password.                 "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Configure Docker repo...                      "
echo "=============================================="
echo ''

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
 	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	Cmd0=`echo $?`
	n=$((n+1))
	sleep 5
done

echo ''
echo "==============================================" 
echo "Configure Docker repo...                      "
echo "=============================================="
echo ''

sleep 5

clear
 
mkdir -p /etc/docker

echo ''
echo "==============================================" 
echo "Install Docker ...                            "
echo "=============================================="
echo ''
 
n=1
Cmd1=1
while [ $Cmd1 -ne 0 ] && [ $n -le 5 ]
do
 	dnf install containerd.io docker-ce docker-ce-cli -y
	Cmd1=`echo $?`
	n=$((n+1))
	sleep 5
done

echo ''
echo "==============================================" 
echo "Done: Install Docker.                         "
echo "=============================================="
echo ''
 
 

