#!/bin/bash

echo ''
echo "==============================================" 
echo "Stop k8s containers...                        "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc stop maestro -f' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc stop violin1 -f' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc stop violin2 -f' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "==============================================" 
echo "Done: Stop k8s containers...                  "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Unmount /lib/modules in container...          "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc config device remove maestro libs' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device remove violin1 libs' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device remove violin2 libs' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "==============================================" 
echo "Done: Unmount /lib/modules in container.      "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "==============================================" 
echo "Start k8s containers...                       "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc start maestro' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start violin1' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start violin2' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "==============================================" 
echo "Done: Start k8s containers...                 "
echo "=============================================="
echo ''

sleep 5

clear
