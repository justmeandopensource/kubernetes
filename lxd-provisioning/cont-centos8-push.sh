GRE=$1

if   [ $GRE = 'N' ]
then
	eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[012345678X].sh maestro/root/' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[012346].sh violin1/root/'    | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[012346].sh violin2/root/'    | sg lxd $CGROUP_SUFFIX"

elif [ $GRE = 'Y' ]
then
	ViolinIndex=3

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


	eval echo "'/var/lib/snapd/snap/bin/lxc file push cont-centos8-[0123469].sh violin$ViolinIndex/root/'    | sg lxd $CGROUP_SUFFIX"
fi
