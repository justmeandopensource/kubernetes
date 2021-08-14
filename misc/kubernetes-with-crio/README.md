# Kubernetes provisioning with CRI-O as container runtime

Follow this documentation to provision a two node (1 master + 1 worker) Kubernetes cluster on __Ubuntu 20.04 LTS__ with __cri-o__ as the container runtime.

Adapt this documentation accordingly if you need more worker nodes.

## Vagrant Environment
|Role|FQDN|IP|OS|RAM|CPU|
|----|----|----|----|----|----|
|Master|kmaster.example.com|172.16.16.100|Ubuntu 20.04|2G|2|
|Worker|kworker1.example.com|172.16.16.101|Ubuntu 20.04|1G|1|

> * Password for the **root** account on all these virtual machines is **kubeadmin**
> * Perform all the commands as root user unless otherwise specified

## Pre-requisites
If you want to try this in a virtualized environment on your workstation
* Virtualbox installed
* Vagrant installed
* Host machine has atleast 4 cores, if you want minimal 2 node k8s cluster
  * 3 cores will be needed
  * 2 for kmaster and 1 for kworker1
* Host machine has atleast 8G memory

## Bring up the virtual machines
We need some virtual machines to work on
```
vagrant up
```

## On all kubernetes nodes (kmaster & kworker1)

##### Disable swap and firewall
```
{

sed -i '/swap/d' /etc/fstab
swapoff -a
systemctl disable --now ufw

}
```

##### Update /etc/hosts
```
cat >>/etc/hosts<<EOF
172.16.16.100   kmaster.example.com     kmaster
172.16.16.101   kworker1.example.com    kworker1
EOF
```

##### Kernel modules and sysctl settings
```
{

cat >>/etc/modules-load.d/crio.conf<<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

}
```

##### Install cri-o container runtime
```
{

OS=xUbuntu_20.04
VERSION=1.20

cat >>/etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list<<EOF
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF

cat >>/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list<<EOF
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers-cri-o.gpg add -

apt update && apt install -qq -y cri-o cri-o-runc cri-tools

cat >>/etc/crio/crio.conf.d/02-cgroup-manager.conf<<EOF
[crio.runtime]
conmon_cgroup = "pod"
cgroup_manager = "cgroupfs"
EOF

systemctl daemon-reload
systemctl enable --now crio

}
```

##### Install Kubernetes components
```
{
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt install -qq -y kubeadm=1.22.0-00 kubelet=1.22.0-00 kubectl=1.22.0-00
}
```

## On the master node (kmaster)

##### Initialize kubernetes cluster
```
kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16
```

##### Deploy network add on - Calico
```
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml
```

##### Generate join command for worker nodes
In case you want to re-generate token to join other nodes
```
kubeadm token create --print-join-command
```

## On worker nodes (kworker1)
##### Join worker node to the cluster
Run the join command from the above step

## Downloading kube config to your local machine
On your host machine
```
mkdir ~/.kube
scp root@172.16.16.100:/etc/kubernetes/admin.conf ~/.kube/config
```
Password for root account is __kubeadmin__ (if you used my Vagrant setup)

## Verifying the cluster
```
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

Have Fun!!