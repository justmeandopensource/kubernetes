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
dnf -y install wget tar 

echo ''
echo "==============================================" 
echo "Done: Install packages.                       "
echo "=============================================="
echo ''

sleep 5

clear

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

if   [ $ContainerRuntime = 'docker' ] || [ $ContainerRuntime = 'containerd' ]
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
		if [ $n -gt 1 ]
		then
			echo ''
			echo 'Re-trying...'
			echo ''
		fi

 		yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

		Cmd0=`echo $?`
		n=$((n+1))
		sleep 5
	done

	echo ''
	echo "==============================================" 
	echo "Done: Configure Docker repo.                  "
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
                if [ $n -gt 1 ]
                then
                        echo ''
                        echo 'Re-trying...'
                        echo ''
                fi

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
 
	sleep 5

	clear 

elif [ $ContainerRuntime = 'crio' ]
then
	echo ''
	echo "==============================================" 
	echo "Install cri-o ...                             "
	echo "=============================================="
	echo ''
 
	VERSION=1.23
	sudo dnf -y install 'dnf-command(copr)'
	sudo dnf -y copr enable rhcontainerbot/container-selinux
	sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/CentOS_8/devel:kubic:libcontainers:stable.repo
	sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:${VERSION}/CentOS_8/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo

	sudo dnf -y install cri-o
	
	echo ''
	echo "==============================================" 
	echo "Done: Install cri-o.                          "
	echo "=============================================="
	echo ''
fi
