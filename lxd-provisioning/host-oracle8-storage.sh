#!/bin/bash

GRE=$1

echo ''
echo "=============================================="
echo "Configure CGROUP_SUFFIX...                    "
echo "=============================================="
echo ''

function GetCgroupv2Warning1 {
	echo "/var/lib/snapd/snap/bin/lxc cluster list" | sg lxd 2> >(grep -c 'WARNING: cgroup v2 is not fully supported yet, proceeding with partial confinement') >/dev/null
}
Cgroupv2Warning1=$(GetCgroupv2Warning1)

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

echo ''
echo "=============================================="
echo "Done: Configure CGROUP_SUFFIX.                "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Configure LXD K8S Storage ...                 "
echo "=============================================="
echo ''

if [ $GRE = 'N' ]
then
	eval echo "'/var/lib/snapd/snap/bin/lxc storage create containerd dir' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create containerd maestro' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create containerd violin1' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create containerd violin2' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add maestro  containerd disk pool=containerd source=maestro  path=/var/lib/containerd' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin1 containerd disk pool=containerd source=violin1 path=/var/lib/containerd' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin2 containerd disk pool=containerd source=violin2 path=/var/lib/containerd' | sg lxd $CGROUP_SUFFIX"

	eval echo "'/var/lib/snapd/snap/bin/lxc storage create kubelet dir' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create kubelet maestro' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create kubelet violin1' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create kubelet violin2' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add maestro  kubelet disk pool=kubelet source=maestro  path=/var/lib/kubelet' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin1 kubelet disk pool=kubelet source=violin1 path=/var/lib/kubelet' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin2 kubelet disk pool=kubelet source=violin2 path=/var/lib/kubelet' | sg lxd $CGROUP_SUFFIX"

	eval echo "'/var/lib/snapd/snap/bin/lxc storage create docker dir' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create docker maestro' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create docker violin1' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create docker violin2' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add maestro  docker disk pool=docker source=maestro  path=/var/lib/docker' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin1 docker disk pool=docker source=violin1 path=/var/lib/docker' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin2 docker disk pool=docker source=violin2 path=/var/lib/docker' | sg lxd $CGROUP_SUFFIX"

elif [ $GRE = 'Y' ]
then
        ViolinIndex=3

        function CheckDNSLookup {
                timeout 5 nslookup violin"$ViolinIndex" $NameServer
        }
        DNSLookup=$(CheckDNSLookup)
        DNSLookup=`echo $?`

        while [ $DNSLookup -eq 0 ]
        do
                ViolinIndex=$((ViolinIndex+1))
                DNSLookup=$(CheckDNSLookup)
                DNSLookup=`echo $?`
        done

        ViolinIndex=$((ViolinIndex-1))

	echo "No storage required."	
#	eval echo "'/var/lib/snapd/snap/bin/lxc storage create containerd dir' | sg lxd $CGROUP_SUFFIX"
#	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create containerd violin$ViolinIndex' | sg lxd $CGROUP_SUFFIX"
#	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin$ViolinIndex containerd disk pool=containerd source=violin$ViolinIndex path=/var/lib/containerd' | sg lxd $CGROUP_SUFFIX"

#	eval echo "'/var/lib/snapd/snap/bin/lxc storage create kubelet dir' | sg lxd $CGROUP_SUFFIX"
#	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create kubelet violin$ViolinIndex' | sg lxd $CGROUP_SUFFIX"
#	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin$ViolinIndex kubelet disk pool=kubelet source=violin$ViolinIndex path=/var/lib/kubelet' | sg lxd $CGROUP_SUFFIX"

#	eval echo "'/var/lib/snapd/snap/bin/lxc storage create docker dir' | sg lxd $CGROUP_SUFFIX"
#	eval echo "'/var/lib/snapd/snap/bin/lxc storage volume create docker violin$ViolinIndex' | sg lxd $CGROUP_SUFFIX"
#	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin$ViolinIndex docker disk pool=docker source=violin1 path=/var/lib/docker' | sg lxd $CGROUP_SUFFIX"
fi

echo ''
echo "=============================================="
echo "Done: Configure LXD K8S Storage.              "
echo "=============================================="
echo ''

