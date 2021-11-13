#!/bin/bash
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubeadm maestro/usr/bin/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubelet maestro/usr/bin/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubectl maestro/usr/bin/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubeadm violin1/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubelet violin1/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubectl violin1/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubeadm violin2/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubelet violin2/usr/bin/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push kubectl violin2/usr/bin/' | sg lxd $CGROUP_SUFFIX"

