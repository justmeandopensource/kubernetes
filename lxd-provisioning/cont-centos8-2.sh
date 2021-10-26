 dnf install -y yum-utils device-mapper-persistent-data lvm2 iproute-tc
 yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
 dnf install containerd.io docker-ce docker-ce-cli -y
 mkdir -p /etc/docker

