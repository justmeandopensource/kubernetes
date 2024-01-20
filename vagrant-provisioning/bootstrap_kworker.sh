#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
export DEBIAN_FRONTEND=noninteractive
apt-get install -qq -y sshpass >/dev/null
sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.example.com:/joincluster.sh /joincluster.sh >/dev/null 2>&1
bash /joincluster.sh >/dev/null
