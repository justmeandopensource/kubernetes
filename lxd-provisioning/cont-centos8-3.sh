#!/bin/bash

ContainerRuntime=$1
Node=$2

if   [ $ContainerRuntime = 'crio' ]
then
	echo ''
	echo "==============================================" 
	echo "Enable and start crio ...                     "
	echo "=============================================="
	echo ''

        ln -s /usr/bin/fuse-overlayfs /usr/local/bin/fuse-overlayfs
	cp -p /root/crio.conf /etc/crio/crio.conf
	systemctl enable crio --now

	echo ''
	echo "==============================================" 
	echo "Done: Enable and start crio.                  "
	echo "=============================================="
	echo ''

        sleep 5

        clear

	echo ''
	echo "==============================================" 
	echo "Run crictl ps ...                             "
	echo "=============================================="
	echo ''

	crictl ps

	echo ''
	echo "==============================================" 
	echo "Done: Run crictl ps.                          "
	echo "=============================================="
	echo ''

	sleep 5

	clear

	echo ''
	echo "==============================================" 
	echo "Run crictl info...                            "
	echo "=============================================="
	echo ''

	crictl info

	echo ''
	echo "==============================================" 
	echo "Run crictl info...                            "
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
