 dnf install -y yum-utils device-mapper-persistent-data lvm2 
 dnf install -y iproute-tc net-tools openssh-server perl bind-utils
 # if LXD container will be running on XFS file system
 # dnf install -y xfsprogs xfsprogs-devel xfsdump 
 systemctl enable sshd
 service sshd start
 dnf remove -y runc
 usermod --password `perl -e "print crypt('root','root');"` root
 
 n=1
 Cmd0=1
 while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
 do
 	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	Cmd0=`echo $?`
	n=$((n+1))
	sleep 5
 done
 
 mkdir -p /etc/docker
 
 n=1
 Cmd1=1
 while [ $Cmd1 -ne 0 ] && [ $n -le 5 ]
 do
 	dnf install containerd.io docker-ce docker-ce-cli -y
	Cmd1=`echo $?`
	n=$((n+1))
	sleep 5
 done
 

