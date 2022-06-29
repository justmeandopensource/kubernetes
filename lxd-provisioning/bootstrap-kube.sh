#!/bin/bash

# This script has been tested on Ubuntu 20.04
# For other versions of Ubuntu, you might need some tweaking

echo "[TASK 0] Install essential packages"
apt install -qq -y net-tools curl ssh software-properties-common >/dev/null 2>&1

echo "[TASK 1] Install containerd runtime"
apt update -qq >/dev/null 2>&1
apt install -qq -y containerd apt-transport-https >/dev/null 2>&1
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null 2>&1

echo "[TASK 2] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

echo "[TASK 3] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -qq -y kubeadm=1.22.0-00 kubelet=1.22.0-00 kubectl=1.22.0-00 >/dev/null 2>&1
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/default/kubelet
systemctl restart kubelet

echo "[TASK 4] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 5] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK 6] Install additional packages"
apt install -qq -y net-tools >/dev/null 2>&1

#######################################
# To be executed only on master nodes #
#######################################

if [[ $(hostname) =~ .*master.* ]]
then

  echo "[TASK 7] Pull required containers"
  kubeadm config images pull >/dev/null 2>&1

  echo "[TASK 8] Initialize Kubernetes Cluster"
  kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all >> /root/kubeinit.log 2>&1

  echo "[TASK 9] Copy kube admin config to root user .kube directory"
  mkdir /root/.kube
  cp /etc/kubernetes/admin.conf /root/.kube/config  

  echo "[TASK 10] Deploy Flannel network"
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml > /dev/null 2>&1

  echo "[TASK 11] Generate and save cluster join command to /joincluster.sh"
  joinCommand=$(kubeadm token create --print-join-command 2>/dev/null) 
  echo "$joinCommand --ignore-preflight-errors=all" > /joincluster.sh

fi

#######################################
# To be executed only on worker nodes #
#######################################

if [[ $(hostname) =~ .*worker.* ]]
then
  echo "[TASK 7] Join node to Kubernetes Cluster"
  apt install -qq -y sshpass >/dev/null 2>&1
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.lxd:/joincluster.sh /joincluster.sh 2>/tmp/joincluster.log
  bash /joincluster.sh >> /tmp/joincluster.log 2>&1
fi
