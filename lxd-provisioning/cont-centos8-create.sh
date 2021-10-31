#!/bin/bash
CGROUP_SUFFIX=$1

eval echo "'/var/lib/snapd/snap/bin/lxc profile create k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
eval echo "'cat k8s-profile-config-weavenet | /var/lib/snapd/snap/bin/lxc profile edit k8s-weavenet' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc init images:centos/8/amd64 kmaster --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start kmaster' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc stop  kmaster' | sg lxd $CGROUP_SUFFIX"
cp ifcfg-eth0-kmaster ifcfg-eth0
eval echo "'/var/lib/snapd/snap/bin/lxc file push ifcfg-eth0 kmaster/etc/sysconfig/network-scripts/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start kmaster' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc init images:centos/8/amd64 kworker1 --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start kworker1' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc stop  kworker1' | sg lxd $CGROUP_SUFFIX"
cp ifcfg-eth0-kworker1 ifcfg-eth0
eval echo "'/var/lib/snapd/snap/bin/lxc file push ifcfg-eth0 kworker1/etc/sysconfig/network-scripts/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start kworker1' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc init images:centos/8/amd64 kworker2 --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start kworker2' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc stop  kworker2' | sg lxd $CGROUP_SUFFIX"
cp ifcfg-eth0-kworker2 ifcfg-eth0
eval echo "'/var/lib/snapd/snap/bin/lxc file push ifcfg-eth0 kworker2/etc/sysconfig/network-scripts/' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc start kworker2' | sg lxd $CGROUP_SUFFIX"

echo 'sleeping for 15 seconds...wait...'
sleep 15

eval echo "'/var/lib/snapd/snap/bin/lxc exec kmaster --  dnf -y install openssh-server net-tools bind-utils' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker1 -- dnf -y install openssh-server net-tools bind-utils' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker2 -- dnf -y install openssh-server net-tools bind-utils' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc exec kmaster --  systemctl enable sshd' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker1 -- systemctl enable sshd' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker2 -- systemctl enable sshd' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc exec kmaster --  service sshd start' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker1 -- service sshd start' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker2 -- service sshd start' | sg lxd $CGROUP_SUFFIX"

eval echo "'/var/lib/snapd/snap/bin/lxc exec kmaster  -- usermod --password `perl -e "print crypt('root','root');"` root' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker1 -- usermod --password `perl -e "print crypt('root','root');"` root' | sg lxd $CGROUP_SUFFIX"
eval echo "'/var/lib/snapd/snap/bin/lxc exec kworker2 -- usermod --password `perl -e "print crypt('root','root');"` root' | sg lxd $CGROUP_SUFFIX"
