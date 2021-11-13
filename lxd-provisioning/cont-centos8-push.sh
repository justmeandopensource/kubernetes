eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[01234567].sh maestro/root/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[012346].sh violin1/root/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[012346].sh violin2/root/'  | sg lxd $CGROUP_SUFFIX"

