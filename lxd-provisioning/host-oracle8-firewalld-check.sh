#!/bin/bash

LinuxFlavor=$1

if   [ $LinuxFlavor = 'Red' ] || [ $LinuxFlavor = 'CentOS' ] || [ $LinuxFlavor = 'Oracle' ] || [ $LinuxFlavor = 'Fedora' ]
then
        function GetFwd1 {
                sudo rpm -qa | grep -c firewalld
        }
	Fwd1=$(GetFwd1)

elif [ $LinuxFlavor = 'Ubuntu' ]
then
        function GetFwd1 {
                sudo dpkg -l | grep -c firewalld
        }
	Fwd1=$(GetFwd1)
fi

function GetFwd2 {
        sudo firewall-cmd --state 2>/dev/null | grep -ic 'running'
}
Fwd2=$(GetFwd2)

echo $Fwd1 $Fwd2

if [ $Fwd1 -ge 1 ] && [ $Fwd2 -ge 1 ]
then
	echo ''
	echo "==============================================" 
	echo "List Firewalld Zone ...                       "
	echo "=============================================="
	echo ''

	sudo firewall-cmd --list-all-zones | grep -A10 public

	echo ''
	echo "==============================================" 
	echo "Done: List Firewalld Zone.                    "
	echo "=============================================="
	echo ''

	sleep 5

	clear
fi
