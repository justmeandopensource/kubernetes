#!/bin/bash

echo ''
echo "==============================================" 
echo "Unmount /lib/modules in container...          "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc config device remove kmaster  libs' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device remove kworker1 libs' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device remove kworker2 libs' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "==============================================" 
echo "Done: Unmount /lib/modules in container.      "
echo "=============================================="
echo ''

sleep 5

clear
