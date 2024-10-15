#!/usr/bin/env bash
set -euo pipefail

# Kubernetes Bootstrapping Script
# Tested on Ubuntu 22.04 - May need tweaking for other versions

# Configuration
KUBERNETES_VERSION="1.31"
CALICO_VERSION="3.28.2"
POD_NETWORK_CIDR="192.168.0.0/16"
ROOT_PASSWORD="kubeadmin"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

handle_error() {
    log "Error on line $1"
    exit 1
}

trap 'handle_error $LINENO' ERR

install_packages() {
    local packages=("$@")
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -qq -y "${packages[@]}"
}

main_tasks() {
    log "TASK 1: Installing essential packages"
    install_packages net-tools curl ssh software-properties-common

    log "TASK 2: Installing containerd runtime"
    install_packages apt-transport-https ca-certificates curl gnupg lsb-release
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    install_packages containerd.io
    containerd config default > /etc/containerd/config.toml
    sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
    systemctl restart containerd
    systemctl enable containerd

    log "TASK 3: Setting up Kubernetes repo"
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

    log "TASK 4: Installing Kubernetes components"
    install_packages kubeadm kubelet kubectl
    echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/default/kubelet
    systemctl restart kubelet

    log "TASK 5: Enabling SSH password authentication"
    sed -i 's/PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
    systemctl reload sshd

    log "TASK 6: Setting root password"
    echo "root:${ROOT_PASSWORD}" | chpasswd
    echo "export TERM=xterm" >> /etc/bash.bashrc
}

# Master node specific tasks
master_tasks() {
    log "TASK 7: Pulling required containers"
    kubeadm config images pull

    log "TASK 8: Initializing Kubernetes Cluster"
    kubeadm init --pod-network-cidr="${POD_NETWORK_CIDR}" --ignore-preflight-errors=all >> /root/kubeinit.log 2>&1

    log "TASK 9: Copying kube admin config"
    mkdir -p /root/.kube
    cp /etc/kubernetes/admin.conf /root/.kube/config

    log "TASK 10: Deploying Calico network"
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/tigera-operator.yaml
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml

    log "TASK 11: Generating cluster join command"
    joinCommand=$(kubeadm token create --print-join-command 2>/dev/null)
    echo "$joinCommand --ignore-preflight-errors=all" > /joincluster.sh
    chmod +x /joincluster.sh
}

# Worker node specific tasks
worker_tasks() {
    log "TASK 7: Joining node to Kubernetes Cluster"
    install_packages sshpass
    sshpass -p "${ROOT_PASSWORD}" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.lxd:/joincluster.sh /joincluster.sh
    bash /joincluster.sh >> /tmp/joincluster.log 2>&1
}

main() {
    main_tasks

    if [[ $(hostname) =~ .*master.* ]]; then
        master_tasks
    elif [[ $(hostname) =~ .*worker.* ]]; then
        worker_tasks
    else
        log "Unknown node type. Exiting."
        exit 1
    fi

    log "Bootstrap completed successfully"
}

main
