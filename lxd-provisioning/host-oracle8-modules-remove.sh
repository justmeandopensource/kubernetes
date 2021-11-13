#!/bin/bash

echo ''
echo "==============================================" 
echo "Unmount /lib/modules in container...          "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc config device remove maestro  libs' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device remove violin1 libs' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device remove violin2 libs' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "==============================================" 
echo "Done: Unmount /lib/modules in container.      "
echo "=============================================="
echo ''

sleep 5

clear
