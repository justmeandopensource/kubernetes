#!/bin/bash
#
#    Copyright 2015-2021 Gilbert Standen
#    This file is part of Orabuntu-LXC.

#    Orabuntu-LXC is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Orabuntu-LXC is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Orabuntu-LXC.  If not, see <http://www.gnu.org/licenses/>.

#    v2.4 		GLS 20151224
#    v2.8 		GLS 20151231
#    v3.0 		GLS 20160710 Updates for Ubuntu 16.04
#    v4.0 		GLS 20161025 DNS DHCP services moved into an LXC container
#    v5.0 		GLS 20170909 Orabuntu-LXC Multi-Host
#    v6.0-AMIDE-beta	GLS 20180106 Orabuntu-LXC AmazonS3 Multi-Host Docker Enterprise Edition (AMIDE)
#    v7.0-ELENA-beta    GLS 20210428 Enterprise LXD Edition New AMIDE

#    Note that this software builds a containerized DNS DHCP solution (bind9 / isc-dhcp-server).
#    The nameserver should NOT be the name of an EXISTING nameserver but an arbitrary name because this software is CREATING a new LXC-containerized nameserver.
#    The domain names can be arbitrary fictional names or they can be a domain that you actually own and operate.
#    There are two domains and two networks because the "seed" LXC containers are on a separate network from the production LXC containers.
#    If the domain is an actual domain, you will need to change the subnet using the subnets feature of Orabuntu-LXC

#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf

clear

echo ''
echo "=============================================="
echo "Deploy ingress-nginx...                       "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Create ingress-nginx namespace...             "
echo "=============================================="
echo ''

kubectl create ns ingress-nginx
echo ''
kubectl get ns ingress-nginx

echo ''
echo "=============================================="
echo "Create ingress-nginx namespace...             "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Download get_helm.sh ...                      "
echo "=============================================="
echo ''

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
	if [ $n -gt 1 ]
	then
		echo ''
		echo 'Re-trying...'
		echo ''
	fi
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	Cmd0=`echo $?`
	n=$((n+1))
	sleep 5
done

chmod 700 get_helm.sh
ls -l get_helm.sh

echo ''
echo "=============================================="
echo "Done: Download get_helm.sh                    "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Download and Install helm...                  "
echo "=============================================="
echo ''
echo '(Patience...this can take a minute or two...)'
echo ''

n=1
Cmd0=1
while [ $Cmd0 -ne 0 ] && [ $n -le 5 ]
do
	if [ $n -gt 1 ]
	then
		echo ''
		echo 'Retrying...'
		echo ''
	fi
	./get_helm.sh
	Cmd0=`echo $?`
	sleep 5
done

echo ''
echo "=============================================="
echo "Done: Download and Install helm.              "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Show helm version...                          "
echo "=============================================="
echo ''

helm version --short

echo ''
echo "=============================================="
echo "Done: Show helm version.                      "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Prepare helm repo ingress-nginx...            "
echo "=============================================="
echo ''

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
echo ''
helm repo update
echo ''
helm repo list
echo ''
helm search repo ingress

echo ''
echo "=============================================="
echo "Prepare helm repo ingress-nginx...            "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Helm install ingress-nginx...                 "
echo "=============================================="
echo ''
echo '(Patience...this can take a minute or two...)'
echo ''

helm install orabuntu-lxd ingress-nginx/ingress-nginx -n ingress-nginx --values /root/ingress-nginx.yaml

echo ''
echo "=============================================="
echo "Helm install ingress-nginx...                 "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Wait for ingress-nginx STATUS running...      "
echo "=============================================="
echo ''

function GetStatus2 {
	kubectl -n ingress-nginx get all | grep -c Running
}
Status2=$(GetStatus2)

while [ $Status2 -lt 2 ]
do
	Status2=$(GetStatus2)
	echo 'Check every 30 seconds STATUS Running all ingress-nginx containers...'
	echo ''
	kubectl -n ingress-nginx get all | egrep 'STATUS|pod'
	echo ''
	sleep 30
done

echo ''
echo "=============================================="
echo "Done: Wait for ingress-nginx STATUS running.  "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Done: Helm install ingress-nginx.             "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Confirm install ingress-nginx...              "
echo "=============================================="
echo ''

kubectl -n ingress-nginx get all

echo ''
echo "=============================================="
echo "Done: Confirm install ingress-nginx.          "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Helm confirm install ingress-nginx...         "
echo "=============================================="
echo ''

helm list -n ingress-nginx

echo ''
echo "=============================================="
echo "Done: Helm confirm install ingress-nginx.     "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Test ingress-nginx/metallb examples...        "
echo "=============================================="
echo ''

function UpdateHostsFile {
        kubectl -n ingress-nginx get all | grep LoadBalancer | sed 's/  */ /g' | cut -f4 -d' '
}
HostsFile=$(UpdateHostsFile)
sh -c "echo '$HostsFile nginx.example.com' >> /etc/hosts"

kubectl create -f nginx-deploy-main.yaml -f nginx-deploy-green.yaml -f nginx-deploy-blue.yaml 

function GetStatus3 {
	kubectl get pods | grep -c Running
}
Status3=$(GetStatus3)

n=1
while [ $Status3 -lt 4 ] && [ $n -lt 5 ]
do
	kubectl get pods 
	Status3=$(GetStatus3)
	n=$((n+1))
	sleep 5
done
	
kubectl expose deploy nginx-deploy-main  --port 80
kubectl expose deploy nginx-deploy-blue  --port 80
kubectl expose deploy nginx-deploy-green --port 80
echo ''
kubectl get all
echo ''
kubectl create -f ingress-resource-3.yaml 
echo ''
echo 'Wait 30 seconds...'
sleep 30
kubectl describe ing ingress-resource-3
echo ''
curl nginx.example.com
echo ''
curl nginx.example.com/blue
echo ''
curl nginx.example.com/green

echo ''
echo "=============================================="
echo "Done: Test ingress-nginx/metallb examples.    "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Done: Deploy ingress-nginx.                   "
echo "=============================================="
echo ''

# sudo iptables -t nat -A PREROUTING -p tcp -i enp0s17 --dport 80 -j DNAT --to-destination 10.209.53.240:80

