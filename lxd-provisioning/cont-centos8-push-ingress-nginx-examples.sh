eval echo "'/var/lib/snapd/snap/bin/lxc file push nginx-deploy-*.yaml maestro/root/'      | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc file push ingress-resource-*.yaml maestro/root/'  | sg lxd $CGROUP_SUFFIX"

