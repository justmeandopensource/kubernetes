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
while [ $Cmd0 -eq 1 ] && [ $n -le 5 ]
do
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	Cmd0=`echo $?`
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

./get_helm.sh

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
echo 'Wait 20 seconds...'
sleep 20
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

