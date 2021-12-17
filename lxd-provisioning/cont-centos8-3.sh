#!/bin/bash

ContainerRuntime=$1

if   [ $ContainerRuntime = 'docker' ]
then
	echo ''
	echo "==============================================" 
	echo "Enable and start Docker ...                   "
	echo "=============================================="
	echo ''

	systemctl daemon-reload
	systemctl enable docker --now
	systemctl start  docker
	service docker start

	echo ''
	echo "==============================================" 
	echo "Done: Enable and start Docker ...             "
	echo "=============================================="
	echo ''

	sleep 5

	clear

elif [ $ContainerRuntime ='crio' ]
then
	ln -s /usr/bin/fuse-overlayfs /usr/local/bin/fuse-overlayfs
	cp -p /root/crio.conf /etc/crio/crio.conf
fi

# echo ''
# echo "=============================================="
# echo "Build kubernetes v1.23 from source...         "
# echo "Takes quite awhile ... patience ... wait ...  "
# echo "=============================================="
# echo ''

# sleep 5

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

# echo ''
# echo "=============================================="
# echo "Done: Build kubernetes v1.23 from source.     "
# echo "=============================================="
# echo ''

# sleep 5
