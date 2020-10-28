
# Provision Kubernetes cluster with kubeadm using external Etcd cluster
> __Ubuntu 20.04 LTS__ is used for etcd and kubernetes nodes

## Pre-Requisites
* You followed 2 simple-cluster-tls.md documentation and have a 3 node etcd cluster running

## Vagrant Environment
|Role|FQDN|IP|OS|RAM|CPU|
|----|----|----|----|----|----|
|Etcd 1|etcd1.example.com|172.16.16.221|Ubuntu 20.04|1G|1|
|Etcd 2|etcd2.example.com|172.16.16.222|Ubuntu 20.04|1G|1|
|Etcd 3|etcd3.example.com|172.16.16.223|Ubuntu 20.04|1G|1|
|Master|kmaster.example.com|172.16.16.100|Ubuntu 20.04|2G|2|
|Worker|kworker1.example.com|172.16.16.101|Ubuntu 20.04|1G|1|


## Copy TLS certificates to kubernetes master node
From your local machine, in the directory where you have the certificates you originally generated
```
scp ca.pem etcd.pem etcd-key.pem root@172.16.16.100:
```

## On both Kmaster and Kworker
Perform all the commands as root user unless otherwise specified
##### Disable Firewall
```
ufw disable
```
##### Disable swap
```
swapoff -a; sed -i '/swap/d' /etc/fstab
```
##### Update sysctl settings for Kubernetes networking
```
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```
##### Install docker engine
```
{
  apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt update
  apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io
}
```
### Kubernetes Setup
##### Add Apt repository
```
{
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
}
```
##### Install Kubernetes components
```
apt update && apt install -y kubeadm=1.19.2-00 kubelet=1.19.2-00 kubectl=1.19.2-00
```

## On kmaster
##### Copy etcd certificates to a standard location
Assuming you are in the root's home directory where you have the certificates copied to earlier
```
{
  mkdir -p /etc/kubernetes/pki/etcd
  mv ca.pem etcd.pem etcd-key.pem /etc/kubernetes/pki/etcd/
}
```
##### Create Cluster Configuration
We need this config file to specify that we are going to be using an external etcd cluster
```
{

ETCD1_IP="172.16.16.221"
ETCD2_IP="172.16.16.222"
ETCD3_IP="172.16.16.223"

cat <<EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
networking:
  podSubnet: "192.168.0.0/16"
etcd:
    external:
        endpoints:
        - https://${ETCD1_IP}:2379
        - https://${ETCD2_IP}:2379
        - https://${ETCD3_IP}:2379
        caFile: /etc/kubernetes/pki/etcd/ca.pem
        certFile: /etc/kubernetes/pki/etcd/etcd.pem
        keyFile: /etc/kubernetes/pki/etcd/etcd-key.pem
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: "172.16.16.100"
EOF

}
```
##### Initialize Kubernetes Cluster
Update the below command with the ip address of kmaster
```
kubeadm init --config kubeadm-config.yaml --ignore-preflight-errors=all
```
##### Deploy Calico network
```
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
```

##### Cluster join command
```
kubeadm token create --print-join-command
```

##### To be able to run kubectl commands as non-root user
If you want to be able to run kubectl commands as non-root user, then as a non-root user perform these
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## On Kworker
##### Join the cluster
Use the output from __kubeadm token create__ command in previous step from the master server and run here.