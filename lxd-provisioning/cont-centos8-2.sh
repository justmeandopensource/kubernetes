#!/bin/bash

ContainerRuntime=$1

echo ''
echo "==============================================" 
echo "Install packages...                           "
echo "=============================================="
echo ''

dnf -y install yum-utils device-mapper-persistent-data lvm2 epel-release
dnf -y install iproute-tc net-tools openssh-server perl bind-utils
dnf -y install epel-release
dnf -y install sshpass

echo ''
echo "==============================================" 
echo "Done: Install packages.                       "
echo "=============================================="
echo ''

# if LXD container will be running on XFS file system
# dnf install -y xfsprogs xfsprogs-devel xfsdump 

echo ''
echo "==============================================" 
echo "Enable and tune sshd...                       "
echo "=============================================="
echo ''

systemctl enable sshd
service sshd start
sed -i '/GSSAPIAuthentication no/s/^#//g' 			/etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' 	/etc/ssh/sshd_config
sed -i '/UseDNS/s/^#//g' 					/etc/ssh/sshd_config
sed -i 's/UseDNS yes/UseDNS no/' 				/etc/ssh/sshd_config
service sshd stop
service sshd start
service sshd status

echo ''
echo "==============================================" 
echo "Done: Enable and tune sshd.                   "
echo "=============================================="
echo ''

sleep 5

clear

if [ $ContainerRuntime = 'docker' ]
then
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
fi

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

if   [ $ContainerRuntime = 'docker' ]
then
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
		echo ''
		echo 'Re-trying...'
		echo ''
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
		echo ''
		echo 'Re-trying...'
		echo ''
		sleep 5
	done

	echo ''
	echo "==============================================" 
	echo "Done: Install Docker.                         "
	echo "=============================================="
	echo ''
 
	sleep 5

	clear 

elif [ $ContainerRuntime = 'containerd' ]
then
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
		echo ''
		echo 'Re-trying...'
		echo ''
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
	echo "Install Containerd ...                        "
	echo "=============================================="
	echo ''
 
	n=1
	Cmd1=1
	while [ $Cmd1 -ne 0 ] && [ $n -le 5 ]
	do
		dnf -y update
	 	dnf -y install containerd.io
		Cmd1=`echo $?`
		n=$((n+1))
		echo ''
		echo 'Re-trying...'
		echo ''
		sleep 5
	done

	echo ''
	echo "==============================================" 
	echo "Done: Install Containerd ...                  "
	echo "=============================================="
	echo ''

	mkdir -p /etc/containerd
	containerd config default > /etc/containerd/config.toml
 
	sleep 5

	clear 

elif [ $ContainerRuntime = 'crio' ]
then
	VERSION=1.22
	sudo dnf -y install 'dnf-command(copr)'
	sudo dnf -y copr enable rhcontainerbot/container-selinux
	sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/CentOS_8/devel:kubic:libcontainers:stable.repo
	sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:${VERSION}/CentOS_8/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo

	sudo dnf -y install cri-o
fi
