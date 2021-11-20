#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf

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

echo ''
echo "=============================================="
echo "Download helm...                              "
echo "=============================================="
echo ''

clear
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh

echo ''
echo "=============================================="
echo "Done: Download helm.                          "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Install helm...                               "
echo "=============================================="
echo ''

./get_helm.sh

echo ''
echo "=============================================="
echo "Done: Install helm.                           "
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
	echo 'Waiting for ingress-nginx STATUS Running all containers...'
	sleep 5
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

# sudo iptables -t nat -A PREROUTING -p tcp -i enp0s17 --dport 80 -j DNAT --to-destination 10.209.53.240:80

