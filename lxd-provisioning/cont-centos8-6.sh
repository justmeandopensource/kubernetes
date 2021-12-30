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

elif [ $ContainerRuntime = 'crio' ]
then
	echo ''
	echo "==============================================" 
	echo "Run crio conversion steps on $Node...         "
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
	echo "Done: Run crio conversion steps.              "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Configure cri-o repo  ...                     "
	echo "=============================================="
	echo ''

        VERSION=1.23
        sudo dnf -y install 'dnf-command(copr)'
        sudo dnf -y copr enable rhcontainerbot/container-selinux

	echo ''
	echo "==============================================" 
	echo "Done: Configure cri-o repo.                   "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Download cri-o ...                            "
	echo "=============================================="
	echo ''

        sudo curl --http1.1 -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/CentOS_8/devel:kubic:libcontainers:stable.repo
        sudo curl --http1.1 -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:${VERSION}/CentOS_8/devel:kubic:libcontainers:stable:cri-o:${VERSION}.repo

	echo ''
	echo "==============================================" 
	echo "Done: Download cri-o.                         "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Uninstall containerd ...                      "
	echo "=============================================="
	echo ''

	sudo dnf -y remove containerd

	echo ''
	echo "==============================================" 
	echo "Uninstall containerd ...                      "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Install cri-o ...                             "
	echo "=============================================="
	echo ''

        sudo dnf -y install cri-o

	echo ''
	echo "==============================================" 
	echo "Done: Install crio.                           "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Edit crio.conf ...                            "
	echo "=============================================="
	echo ''

	sed -i 's/conmon = \"\"/conmon = \"\/usr\/bin\/conmon\"/'	/etc/crio/crio.conf

	echo ''
	echo "==============================================" 
	echo "Done: Edit crio.conf.                         "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Edit /var/lib/kubelet/kubeadm-flags.env ...   "
	echo "=============================================="
	echo ''
	
	echo ''
	echo "==============================================" 
	echo 'DISPLAY kubeadm-flags.env BEFORE SED'
	echo ''
	cat /var/lib/kubelet/kubeadm-flags.env
	echo ''
	echo "==============================================" 
	sed -i 's/\"/ --feature-gates=AllAlpha=false --container-runtime=remote --cgroup-driver=systemd --container-runtime-endpoint=unix\:\/\/\/var\/run\/crio\/crio.sock --runtime-request-timeout=5m\"/2' /var/lib/kubelet/kubeadm-flags.env
	echo ''
	echo "==============================================" 
	echo 'DISPLAY kubeadm-flags.env AFTER SED'
	echo ''
	cat /var/lib/kubelet/kubeadm-flags.env
	echo ''
	echo "==============================================" 
	sleep 120

	echo ''
	echo "==============================================" 
	echo "Done: Edit /var/lib/kubelet/kubeadm-flags.env "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Enable and start crio ...                     "
	echo "=============================================="
	echo ''

        ln -s /usr/bin/fuse-overlayfs /usr/local/bin/fuse-overlayfs
	cp -p /root/crio.conf /etc/crio/crio.conf
	sed -i 's/conmon = \"\"/conmon = \"\/usr\/bin\/conmon\"/'	/etc/crio/crio.conf
        systemctl daemon-reload
	systemctl enable crio --now
	crictl ps
	crictl info

	echo ''
	echo "==============================================" 
	echo "Done: Enable and start crio.                  "
	echo "=============================================="
	echo ''
        sleep 5

        clear

        echo ''
        echo "=============================================="
        echo "Install podman, skopeo, buildah...            "
        echo "=============================================="
        echo ''

        dnf -y install podman skopeo buildah
        sed -i "/fuse-overlayfs/s/#mount_program/mount_program/g" /etc/containers/storage.conf
        podman run hello-world
        podman ps -a

        echo ''
        echo "=============================================="
        echo "Done: Install podman, skopeo, buildah.        "
        echo "=============================================="
        echo ''

        sleep 5

        clear
fi	
