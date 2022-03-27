#!/bin/bash

GRE=$1

echo ''
echo "=============================================="
echo "Mount /lib/modules  ...                       "
echo "=============================================="
echo ''

if   [ $GRE = 'N' ]
then
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add maestro libs disk source=/lib/modules path=/lib/modules' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin1 libs disk source=/lib/modules path=/lib/modules' | sg lxd $CGROUP_SUFFIX"
	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin2 libs disk source=/lib/modules path=/lib/modules' | sg lxd $CGROUP_SUFFIX"

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

        ViolinIndex=$((ViolinIndex-1))

	eval echo "'/var/lib/snapd/snap/bin/lxc config device add violin$ViolinIndex libs disk source=/lib/modules path=/lib/modules' | sg lxd $CGROUP_SUFFIX"
fi

echo ''
echo "=============================================="
echo "Done: Mount /lib/modules .                    "
echo "=============================================="
echo ''

sleep 5

clear
