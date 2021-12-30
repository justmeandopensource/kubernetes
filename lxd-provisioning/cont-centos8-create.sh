#!/bin/bash
CGROUP_SUFFIX=$2
NameServer=$1

eval echo "'/var/lib/snapd/snap/bin/lxc profile show k8s-weavenet' | sg lxd $CGROUP_SUFFIX" > /dev/null
Cmd0=`echo $?`

if [ $Cmd0 -eq 0 ]
then
	eval echo "'/var/lib/snapd/snap/bin/lxc profile delete k8s-weavenet' | sg lxd $CGROUP_SUFFIX" > /dev/null
fi
	
echo ''
echo "=============================================="
echo "Create k8s-weavenet profile...                "
echo "=============================================="
echo ''

eval echo "'/var/lib/snapd/snap/bin/lxc profile create k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
eval echo "'cat k8s-profile-config-weavenet | /var/lib/snapd/snap/bin/lxc profile edit k8s-weavenet' | sg lxd $CGROUP_SUFFIX"

echo ''
echo "=============================================="
echo "Done: Create k8s-weavenet profile.            "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Configure Kubernetes containers...            "
echo "=============================================="
echo ''

for i in maestro violin1 violin2
do
	eval echo "'/var/lib/snapd/snap/bin/lxc stop -f $i ' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc delete $i '  | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc init images:centos/8/amd64 $i --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
	
	function GetHwaddr {
		eval echo "'/var/lib/snapd/snap/bin/lxc config show $i | grep hwaddr | rev | cut -c1-17 | rev' | sg lxd $CGROUP_SUFFIX"
	}
	Hwaddr=$(GetHwaddr)

	sudo lxc-attach -n $NameServer -- sudo sh -c "echo 'subclass \"black-hole\" $Hwaddr;' >> /etc/dhcp/dhcpd.conf"
	sudo lxc-attach -n $NameServer -- sudo service isc-dhcp-server restart

	eval echo "'/var/lib/snapd/snap/bin/lxc start $i' | sg lxd $CGROUP_SUFFIX"

	cp ifcfg-eth0-$i ifcfg-eth0

	Status=1
	n=1
	while [ $Status -ne 0 ] && [ $n -le 5 ]
	do
		eval echo "'/var/lib/snapd/snap/bin/lxc file push ifcfg-eth0 $i/etc/sysconfig/network-scripts/' | sg lxd $CGROUP_SUFFIX"
		Status=`echo $?`
		n=$((n+1))
		sleep 5
	done

	eval echo "'/var/lib/snapd/snap/bin/lxc stop  $i' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc start $i' | sg lxd $CGROUP_SUFFIX"

	Status=1
	n=1
	while [ $Status -ne 0 ] && [ $n -le 5 ]
	do
		eval echo "'/var/lib/snapd/snap/bin/lxc exec $i -- dnf -y install openssh-server net-tools bind-utils git rsync' | sg lxd $CGROUP_SUFFIX"
		Status=`echo $?`
		n=$((n+1))
		sleep 5
	done

	eval echo "'/var/lib/snapd/snap/bin/lxc exec $i -- systemctl enable sshd' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc exec $i -- service sshd start' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc exec $i -- usermod --password `perl -e "print crypt('root','root');"` root' | sg lxd $CGROUP_SUFFIX"

	if [ -f /sys/fs/cgroup/cgroup.controllers ]
	then
		eval echo "'/var/lib/snapd/snap/bin/lxc config device add "$i" "kmsg" unix-char source="/dev/kmsg" path="/dev/kmsg"' | sg lxd $CGROUP_SUFFIX"
	fi
done

echo ''
echo "=============================================="
echo "Done: Configure Kubernetes containers.        "
echo "=============================================="
echo ''

