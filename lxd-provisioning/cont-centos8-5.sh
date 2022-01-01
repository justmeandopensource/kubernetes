#!/bin/bash
#
#    Copyright 2015-2021 Gilbert Standen
#    This file is part of Orabuntu-LXC.

#    Orabuntu-LXC is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Orabuntu-LXC is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Orabuntu-LXC.  If not, see <http://www.gnu.org/licenses/>.

#    v2.4 		GLS 20151224
#    v2.8 		GLS 20151231
#    v3.0 		GLS 20160710 Updates for Ubuntu 16.04
#    v4.0 		GLS 20161025 DNS DHCP services moved into an LXC container
#    v5.0 		GLS 20170909 Orabuntu-LXC Multi-Host
#    v6.0-AMIDE-beta	GLS 20180106 Orabuntu-LXC AmazonS3 Multi-Host Docker Enterprise Edition (AMIDE)
#    v7.0-ELENA-beta    GLS 20210428 Enterprise LXD Edition New AMIDE

#    Note that this software builds a containerized DNS DHCP solution (bind9 / isc-dhcp-server).
#    The nameserver should NOT be the name of an EXISTING nameserver but an arbitrary name because this software is CREATING a new LXC-containerized nameserver.
#    The domain names can be arbitrary fictional names or they can be a domain that you actually own and operate.
#    There are two domains and two networks because the "seed" LXC containers are on a separate network from the production LXC containers.
#    If the domain is an actual domain, you will need to change the subnet using the subnets feature of Orabuntu-LXC

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
        dnf upgrade -y --refresh
        Cmd0=`echo $?`
        n=$((n+1))
        sleep 5
done
dnf install -y epel-release
dnf install -y sshpass
systemctl enable kubelet.service
# kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all --kubernetes-version=v1.23.0-beta.0 | tee kubeadm_init.log
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all | tee kubeadm_init.log
# kubeadm reset -f
# kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all | tee kubeadm_init.log
echo "Sleeping 30 seconds while kubernetes master starts running ..."
sleep 30
cat kubeadm_init.log | grep -A1 join | grep -A1 token > joincluster.sh
chmod +x joincluster.sh
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile

# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# sleep 30
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# sleep 30
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

sleep 5

echo "Sleeping 30 seconds while weavenet starts running ..."
echo ''
kubectl get pods --all-namespaces -o wide
sleep 30
echo ''
kubectl get pods --all-namespaces -o wide
sleep 30
echo ''
kubectl get pods --all-namespaces -o wide
sleep 30
sed -i '${s/$/ --ignore-preflight-errors=all/}' joincluster.sh
sleep 5
sshpass -p root scp    -o CheckHostIP=no -o StrictHostKeyChecking=no -p /root/joincluster.sh root@10.209.53.5:/root/.
sshpass -p root scp    -o CheckHostIP=no -o StrictHostKeyChecking=no -p /root/joincluster.sh root@10.209.53.6:/root/.
echo ''
sshpass -p root ssh -t -o CheckHostIP=no -o StrictHostKeyChecking=no root@10.209.53.5 "/root/joincluster.sh"
sleep 10
echo ''
sshpass -p root ssh -t -o CheckHostIP=no -o StrictHostKeyChecking=no root@10.209.53.6 "/root/joincluster.sh"

# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# sleep 30
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# sleep 30
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
# sleep 30

clear

echo ''
echo "=============================================="
echo "kubectl describe node maestro...              "
echo "=============================================="
echo ''

kubectl describe node maestro

echo ''
echo "=============================================="
echo "Done: kubectl describe node maestro.          "
echo "=============================================="
echo ''

sleep 10

clear

echo ''
echo "=============================================="
echo "kubectl describe node violin1...              "
echo "=============================================="
echo ''

kubectl describe node violin1

echo ''
echo "=============================================="
echo "Done: kubectl describe node violin1.          "
echo "=============================================="
echo ''

sleep 10

clear

echo ''
echo "=============================================="
echo "kubectl describe node violin2...              "
echo "=============================================="
echo ''

kubectl describe node violin2

echo ''
echo "=============================================="
echo "Done: kubectl describe node violin2.          "
echo "=============================================="
echo ''

sleep 10

clear

