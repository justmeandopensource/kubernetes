#!/bin/bash

ContainerRuntime=$1
Node=$2

if   [ $ContainerRuntime = 'crio' ]
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
