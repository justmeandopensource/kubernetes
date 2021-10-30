#!/bin/bash

function GetApiServerAdvertiseAddress {
	cat cont-centos8-6.sh | grep kmaster | cut -c7-100 | cut -f1 -d' '
}
ApiServerAdvertiseAddress=$(GetApiServerAdvertiseAddress)
systemctl enable kubelet.service
kubeadm init --pod-network-cidr=10.96.0.0/16 --apiserver-advertise-address=$ApiServerAdvertiseAddress=
export KUBECONFIG=/etc/kubernetes/admin.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
