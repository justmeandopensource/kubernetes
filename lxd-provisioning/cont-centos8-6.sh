#!/bin/bash

ContainerRuntime=$1
Node=$2

if   [ $ContainerRuntime = 'containerd' ]
then
	echo ''
	echo "==============================================" 
	echo "Run containerd conversion steps on $Node...   "
	echo "=============================================="
	echo ''

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

	echo ''
	echo "==============================================" 
	echo "Done: Run containerd conversion steps.        "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Edit /etc/containerd/config.toml...           "
	echo "=============================================="
	echo ''

	sed -i 's/disabled_plugins/# disabled_plugins/g'                                /etc/containerd/config.toml
	sed -i '/containerd.runtimes.runc.options/a \            \SystemdCgroup = true' /etc/containerd/config.toml
	cat /etc/containerd/config.toml | egrep 'disabled_plugins|SystemdCgroup'

	echo ''
	echo "==============================================" 
	echo "Done: Edit /etc/containerd/config.toml.       "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Edit /var/lib/kubelet/kubeadm-flags.env ...   "
	echo "=============================================="
	echo ''
	
	sed -i 's/\"/ --container-runtime=remote --container-runtime-endpoint=\/run\/containerd\/containerd.sock/2' /var/lib/kubelet/kubeadm-flags.env
	cat /var/lib/kubelet/kubeadm-flags.env

	echo ''
	echo "==============================================" 
	echo "Done: Edit /var/lib/kubelet/kubeadm-flags.env "
	echo "=============================================="
	echo ''

	sleep 5

	clear
fi	
