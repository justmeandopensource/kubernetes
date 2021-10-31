#!/bin/bash

if [ $Cgroupv2Warning1 -eq 1 ]
then
        echo "=============================================="
        echo "On $LinuxFlavor $RedHatVersion the WARNING:   "
        echo "                                              "
        echo "WARNING: cgroup v2 is not fully supported yet "
        echo "proceeding with partial confinement.          "
        echo "                                              "
        echo "can be safely IGNORED.                        "
        echo "This is a snapd issue not an LXD issue.       "
        echo "                                              "
        echo "This specific warning has been suppressed     "
        echo "during this install of Orabuntu-LXC.          "
        echo "                                              "
        echo " More info here:                              "
        echo "                                              "
        echo "https://discuss.linuxcontainers.org/t/lxd-cgroup-v2-support/10455"
        echo "https://bugs.launchpad.net/ubuntu/+source/snapd/+bug/1850667"
        echo "                                              "
        echo "=============================================="

        CGROUP_SUFFIX='2>/dev/null'
else
        CGROUP_SUFFIX=''
fi

sleep 5

clear

eval echo "'/var/lib/snapd/snap/bin/lxc storage create containerd dir' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create containerd kmaster' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create containerd kworker1' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create containerd kworker2' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kmaster  containerd disk pool=containerd source=kmaster  path=/var/lib/containerd' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker1 containerd disk pool=containerd source=kworker1 path=/var/lib/containerd' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker2 containerd disk pool=containerd source=kworker2 path=/var/lib/containerd' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc storage create kubelet dir' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create kubelet kmaster' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create kubelet kworker1' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create kubelet kworker2' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kmaster  kubelet disk pool=kubelet source=kmaster  path=/var/lib/kubelet' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker1 kubelet disk pool=kubelet source=kworker1 path=/var/lib/kubelet' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker2 kubelet disk pool=kubelet source=kworker2 path=/var/lib/kubelet' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc storage create docker dir' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create docker kmaster' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create docker kworker1' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create docker kworker2' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kmaster  docker disk pool=docker source=kmaster  path=/var/lib/docker' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker1 docker disk pool=docker source=kworker1 path=/var/lib/docker' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker2 docker disk pool=docker source=kworker2 path=/var/lib/docker' | sg lxd $CGROUP_SUFFIX"

