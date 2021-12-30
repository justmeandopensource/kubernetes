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

echo ''
echo "=============================================="
echo "Run kubeadm reset ...                         "
echo "=============================================="
echo ''

kubeadm reset -f

echo ''
echo "=============================================="
echo "Done: Run kubeadm reset.                      "
echo "=============================================="
echo ''

sleep 5

clear
echo ''
echo "=============================================="
echo "Install Kubernetes ...                        "
echo "=============================================="
echo ''

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

echo ''
echo "=============================================="
echo "Done: Install Kubernetes .                    "
echo "=============================================="
echo ''

sleep 5

clear
       
if   [ $ContainerRuntime = 'docker' ] || [ $ContainerRuntime = 'containerd' ]
then
        echo ''
        echo "=============================================="
        echo "Enable and start Docker ...                   "
        echo "=============================================="
        echo ''

        systemctl daemon-reload
        systemctl enable docker --now
	service docker start
	containerd config default > /etc/containerd/config.toml
	service containerd restart

        echo ''
        echo "=============================================="
        echo "Done: Enable and start Docker ...             "
        echo "=============================================="
        echo ''

        sleep 5

        clear

elif [ $ContainerRuntime = 'crio ' ]
then
        echo ''
        echo "=============================================="
        echo "sed kubeadm-flags.env for crio ...            "
        echo "=============================================="
        echo ''

	echo 'run sed step on /var/lib/kubelet/kubeadm-flags.env'
	sleep 120
        
	echo ''
        echo "=============================================="
        echo "Done: sed kubeadm-flags.env for crio.         "
        echo "=============================================="
        echo ''
fi

echo ''
echo "=============================================="
echo "Enable kubelet service...                     "
echo "=============================================="
echo ''

systemctl enable kubelet --now

sleep 5

clear

echo ''
echo "=============================================="
echo "Done: Enable kubelet service.                 "
echo "=============================================="
echo ''

sleep 5

clear


