#!/bin/bash
CGROUP_SUFFIX=$1
eval echo "'/var/lib/snapd/snap/bin/lxc exec kmaster -- /root/cont-centos8-0.sh' | sg lxd $CGROUP_SUFFIX"