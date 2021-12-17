#!/bin/bash

ContainerRuntime=$1

echo ''
echo "=============================================="
echo "Install Kubernetes ...                        "
echo "=============================================="
echo ''

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

echo ''
echo "=============================================="
echo "Done: Install Kubernetes .                    "
echo "=============================================="
echo ''

sleep 5

clear

if [ $ContainerRuntime = 'crio' ]
then
	echo ''
	echo "=============================================="
	echo "Enable and start cri-o ...                    "
	echo "=============================================="
	echo ''

        systemctl enable crio --now
        systemctl start  crio
        service crio start
	sudo sh -c "echo 'KUBELET_EXTRA_ARGS=--container-runtime=remote --cgroup-driver=systemd --container-runtime-endpoint=\"unix:///var/run/crio/crio.sock\"' > /etc/sysconfig/kubelet"
	
	echo ''
	echo "=============================================="
	echo "Enable and start cri-o ...                    "
	echo "=============================================="
	echo ''
fi

echo ''
echo "=============================================="
echo "Enable kubelet service...                     "
echo "=============================================="
echo ''

systemctl enable kubelet

echo ''
echo "=============================================="
echo "Done: Enable kubelet service.                 "
echo "=============================================="
echo ''

sleep 5

clear


