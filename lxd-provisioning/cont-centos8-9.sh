GRE=$1
NameServer=$2

# literal value
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

echo ''
echo "=============================================="
echo "Join violin$ViolinIndex to k8s cluster...     "
echo "=============================================="
echo ''

sshpass -p root scp -o CheckHostIP=no -o StrictHostKeyChecking=no -p root@maestro:/root/joincluster.sh .
/root/joincluster.sh

echo ''
echo "=============================================="
echo "Done: Join violin$ViolinIndex  to k8s cluster."
echo "=============================================="
echo ''

sleep 5

clear

