eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[01234567].sh kmaster/root/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[012346].sh kworker1/root/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[012346].sh kworker2/root/'  | sg lxd $CGROUP_SUFFIX"

