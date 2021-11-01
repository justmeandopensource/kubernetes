#!/bin/bash

echo ''
echo "=============================================="
echo "Configure K8S Storage...                      "
echo "=============================================="
echo ''

sudo mount /dev/zfs_luns/zfs_cont_01_00 /var/lib/containerd
sudo mount /dev/zfs_luns/zfs_kube_01_00 /var/lib/kubelet
sudo mount /dev/zfs_luns/zfs_dock_01_00 /var/lib/docker

echo ''
echo "=============================================="
echo "Done: Configure K8S Storage...                "
echo "=============================================="
echo ''

sleep 5

clear
