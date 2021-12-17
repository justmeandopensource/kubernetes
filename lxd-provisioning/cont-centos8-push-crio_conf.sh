eval echo "'/var/lib/snapd/snap/bin/lxc file push crio.conf maestro/root/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push crio.conf violin1/root/'  | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push crio.conf violin2/root/'  | sg lxd $CGROUP_SUFFIX"

