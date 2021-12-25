#!/bin/bash

ContainerRuntime=$1

echo ''
echo "=============================================="
echo "Source build (if needed) ...                  "
echo "=============================================="
echo ''

echo 'Source builds go here if needed.'

sleep 5

clear

# echo ''
# echo "=============================================="
# echo "Clone kubernetes github...                    "
# echo "=============================================="
# echo ''

# git clone https://github.com/kubernetes/kubernetes

# echo ''
# echo "=============================================="
# echo "Done: Clone kubernetes github.                "
# echo "=============================================="
# echo ''

# sleep 5

# echo ''
# echo "=============================================="
# echo "Make kubernetes quick-release...              "
# echo "=============================================="
# echo ''

# cd kubernetes
# make -d quick-release
# Cmd0=`echo $?`

# if [ $Cmd0 -ne 0 ]
# then
# 	make quick-release
# 	Cmd0=`echo $?`
# fi

# echo ''
# echo "=============================================="
# echo "Make kubernetes quick-release...              "
# echo "=============================================="
# echo ''

# sleep 5

# echo ''
# echo "=============================================="
# echo "Copy k8s binaries to /usr/bin...              "
# echo "=============================================="
# echo ''

# cp -p /root/kubernetes/_output/dockerized/bin/linux/amd64/kubeadm /usr/bin/.
# cp -p /root/kubernetes/_output/dockerized/bin/linux/amd64/kubectl /usr/bin/.
# cp -p /root/kubernetes/_output/dockerized/bin/linux/amd64/kubelet /usr/bin/.
# ls -l /usr/bin/kube*

# echo ''
# echo "=============================================="
# echo "Copy k8s binaries to /usr/bin...              "
# echo "=============================================="
# echo ''

# sleep 5

# clear

echo ''
echo "=============================================="
echo "Done: Source builds (if needed).              "
echo "=============================================="
echo ''

sleep 5

clear
