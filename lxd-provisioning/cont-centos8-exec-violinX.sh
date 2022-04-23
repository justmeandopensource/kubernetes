#!/bin/bash
ContainerRuntime=$1
NameServer=$2

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

eval echo "'/var/lib/snapd/snap/bin/lxc exec violin$ViolinIndex -- /root/cont-centos8-0.sh $ContainerRuntime' | sg lxd"
eval echo "'/var/lib/snapd/snap/bin/lxc exec violin$ViolinIndex -- /root/cont-centos8-9.sh $GRE $NameServer'  | sg lxd"
