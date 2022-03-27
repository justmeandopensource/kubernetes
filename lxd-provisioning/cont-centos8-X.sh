GRE=$1
NameServer=$2

if [ $GRE = 'Y' ]
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

	sshpass -p root scp    -o CheckHostIP=no -o StrictHostKeyChecking=no -p /root/joincluster.sh root@violin$ViolinIndex:/root/.
fi
