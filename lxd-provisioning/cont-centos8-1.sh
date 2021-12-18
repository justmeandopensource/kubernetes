#!/bin/bash

ContainerRuntime=$1

if   [ $ContainerRuntime = 'docker' ]
then
	echo ''
	echo "==============================================" 
	echo "Install Docker daemon.json ...                "
	echo "=============================================="
	echo ''

	mkdir -p /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF
	cat /etc/docker/daemon.json

	echo ''
	echo "==============================================" 
	echo "Done: Install Docker daemon.json.             "
	echo "=============================================="
	echo ''

elif [ $ContainerRuntime = 'crio' ]
then
	dnf -y install fuse-overlayfs
fi

sleep 5

clear
