 dnf install -y yum-utils device-mapper-persistent-data lvm2 
 dnf install -y iproute-tc net-tools openssh-server perl bind-utils
 # if LXD container will be running on XFS file system
 # dnf install -y xfsprogs xfsprogs-devel xfsdump 
 systemctl enable sshd
 service sshd start
 dnf remove -y runc
 usermod --password `perl -e "print crypt('root','root');"` root
 yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
 dnf install containerd.io docker-ce docker-ce-cli -y
 mkdir -p /etc/docker

