#!/bin/bash

echo ''
echo "=============================================="
echo "Mount /lib/modules  ...                       "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc config device add kmaster  libs disk source=/lib/modules path=/lib/modules' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker1 libs disk source=/lib/modules path=/lib/modules' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc config device add kworker2 libs disk source=/lib/modules path=/lib/modules' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Done: Mount /lib/modules .                    "
echo "=============================================="
echo ''

sleep 5

clear