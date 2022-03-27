#!/bin/bash

NameServer=$1
Domain1=$2
GRE=$3
CGROUP_SUFFIX=$4

if   [ $GRE = 'N' ]
then
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
		eval echo "'/var/lib/snapd/snap/bin/lxc stop -f $i ' | sg lxd $CGROUP_SUFFIX" >/dev/null 2>&1
		eval echo "'/var/lib/snapd/snap/bin/lxc delete $i '  | sg lxd $CGROUP_SUFFIX" >/dev/null 2>&1

		Status=1
		n=1
		while [ $Status -ne 0 ] && [ $n -le 5 ]
		do
			eval echo "'/var/lib/snapd/snap/bin/lxc init images:centos/8-Stream $i --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
			Status=`echo $?`
			n=$((n+1))
			sleep 5
		done
	
		function GetHwaddr {
			eval echo "'/var/lib/snapd/snap/bin/lxc config show $i | grep hwaddr | rev | cut -c1-17 | rev' | sg lxd $CGROUP_SUFFIX"
		}
		Hwaddr=$(GetHwaddr)

		sudo lxc-attach -n $NameServer -- sudo sh -c "echo 'subclass \"black-hole\" $Hwaddr;' >> /etc/dhcp/dhcpd.conf"
		sudo lxc-attach -n $NameServer -- sudo service isc-dhcp-server restart

		eval echo "'/var/lib/snapd/snap/bin/lxc start $i' | sg lxd $CGROUP_SUFFIX"
	
		sed -i "s/orabuntu-lxc.com/$Domain1/g" ifcfg-eth0-$i 
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

elif [ $GRE = 'Y' ]
then
	ViolinIndex=1

	function CheckDNSLookup {
        	timeout 5 nslookup violin"$ViolinIndex" $NameServer
	}
	DNSLookup=$(CheckDNSLookup)
	DNSLookup=`echo $?`

	while [ $DNSLookup -eq 0 ]
	do
        	ViolinIndex=$((ViolinIndex+1))
        	DNSLookup=$(CheckDNSLookup)
        	DNSLookup=`echo $?`
	done

	i=violin$ViolinIndex

	eval echo "'/var/lib/snapd/snap/bin/lxc stop -f $i ' | sg lxd $CGROUP_SUFFIX" >/dev/null 2>&1
	eval echo "'/var/lib/snapd/snap/bin/lxc delete $i '  | sg lxd $CGROUP_SUFFIX" >/dev/null 2>&1

	Status=1
	n=1
	while [ $Status -ne 0 ] && [ $n -le 5 ]
	do
		eval echo "'/var/lib/snapd/snap/bin/lxc init images:centos/8-Stream $i --profile k8s-weavenet' | sg lxd $CGROUP_SUFFIX"
		Status=`echo $?`
		n=$((n+1))
		sleep 5
	done
	
	function GetHwaddr {
		eval echo "'/var/lib/snapd/snap/bin/lxc config show $i | grep hwaddr | rev | cut -c1-17 | rev' | sg lxd $CGROUP_SUFFIX"
	}
	Hwaddr=$(GetHwaddr)

	sudo lxc-attach -n $NameServer -- sudo sh -c "echo 'subclass \"black-hole\" $Hwaddr;' >> /etc/dhcp/dhcpd.conf"
	sudo lxc-attach -n $NameServer -- sudo service isc-dhcp-server restart

	eval echo "'/var/lib/snapd/snap/bin/lxc start $i' | sg lxd $CGROUP_SUFFIX"
	
	sed -i "s/orabuntu-lxc.com/$Domain1/g" ifcfg-eth0-$i 
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
fi

echo ''
echo "=============================================="
echo "Done: Configure Kubernetes containers.        "
echo "=============================================="
echo ''

