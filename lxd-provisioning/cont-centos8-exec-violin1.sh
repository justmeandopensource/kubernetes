#!/bin/bash
CGROUP_SUFFIX=$1
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin1 -- /root/cont-centos8-0.sh' | sg lxd $CGROUP_SUFFIX"
