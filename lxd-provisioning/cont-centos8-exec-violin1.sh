#!/bin/bash
ContainerRuntime=$1
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin1 -- /root/cont-centos8-0.sh $ContainerRuntime' | sg lxd"
