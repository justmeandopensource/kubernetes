#!/bin/bash
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubeadm kmaster/usr/bin/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubelet kmaster/usr/bin/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubectl kmaster/usr/bin/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubeadm kworker1/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubelet kworker1/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubectl kworker1/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubeadm kworker2/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubelet kworker2/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubectl kworker2/usr/bin/' | sg lxd $CGROUP_SUFFIX"

