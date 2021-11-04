#!/bin/bash

echo ''
echo "==============================================" 
echo "Install EPEL...                               "
echo "=============================================="
echo ''

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -lt 5 ]
do
	dnf install -y epel-releasea
	Cmd0=`echo $?`
	n=$((n+1))
	sleep 5
done

echo ''
echo "==============================================" 
echo "Done: Install EPEL.                           "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Install sshpass...                            "
echo "=============================================="
echo ''

n=1
Cmd1=1
while [ $Cmd1 -ne 0 ] && [ $n -lt 5 ]
do
	dnf install -y sshpass
	Cmd1=`echo $?`
	n=$((n+1))
	sleep 5
done

echo ''
echo "==============================================" 
echo "Install sshpass...                            "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Enable kubelet service...                     "
echo "=============================================="
echo ''

systemctl enable kubelet.service

echo ''
echo "==============================================" 
echo "Done: Enable kubelet service.                 "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Turn off swap...                              "
echo "=============================================="
echo ''

sudo swapoff -a
sudo free -m

echo ''
echo "==============================================" 
echo "Done: Turn off swap.                          "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Run kubeadm...                                "
echo "=============================================="
echo ''

kubeadm init --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.23.0-alpha.3 | tee kubeadm_init.log

echo ''
echo "==============================================" 
echo "Done: Run kubeadm.                            "
echo "=============================================="
echo ''

sleep 5

clear

echo "Sleeping 30 seconds while kubernetes master starts running ..."
sleep 30

echo ''
echo "==============================================" 
echo "Configure environment...                      "
echo "=============================================="
echo ''

export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
cat /etc/kubernetes/admin.conf

echo ''
echo "==============================================" 
echo "Done: Configure environment.                  "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Install weavenet...                           "
echo "=============================================="
echo ''

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo ''
echo "==============================================" 
echo "Done: Install weavenet.                       "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Monitor controller startup status...          "
echo "=============================================="
echo ''

echo "Sleeping 30 seconds while cluster starts up ..."
echo ''

kubectl get pods --all-namespaces -o wide

sleep 20

echo "Sleeping 30 seconds while cluster starts up ..."
echo ''

echo ''
kubectl get pods --all-namespaces -o wide

sleep 20

echo "Sleeping 30 seconds while cluster starts up ..."
echo ''

kubectl get pods --all-namespaces -o wide
sleep 20

echo ''
echo "==============================================" 
echo "Done: Monitor controller startup status.      "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Join cluster nodes...                         "
echo "=============================================="
echo ''

cat kubeadm_init.log | grep -A1 join | grep -A1 token > joincluster.sh
chmod +x joincluster.sh

sshpass -p root scp    -o CheckHostIP=no -o StrictHostKeyChecking=no -p /root/joincluster.sh root@10.207.39.5:/root/.
sshpass -p root scp    -o CheckHostIP=no -o StrictHostKeyChecking=no -p /root/joincluster.sh root@10.207.39.6:/root/.

echo ''
sshpass -p root ssh -t -o CheckHostIP=no -o StrictHostKeyChecking=no root@10.207.39.5 "/root/joincluster.sh"
sleep 10

echo ''
sshpass -p root ssh -t -o CheckHostIP=no -o StrictHostKeyChecking=no root@10.207.39.6 "/root/joincluster.sh"
sleep 10

echo ''
echo "==============================================" 
echo "Done: Join cluster nodes.                     "
echo "=============================================="
echo ''

