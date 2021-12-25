#!/bin/bash

ContainerRuntime=$1

if   [ $ContainerRuntime = 'docker' ] || [ $ContainerRuntime = 'containerd' ]
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
fi

sleep 5

clear
