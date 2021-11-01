#!/bin/bash

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

echo ''
echo "==============================================" 
echo "Done: Install Docker daemon.json.             "
echo "=============================================="
echo ''

sleep 5

clear
