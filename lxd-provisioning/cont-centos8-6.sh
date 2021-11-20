#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf

# Deploy metallb load balancer

echo ''
echo "=============================================="
echo "Install Metallb k8s load balancer...          "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Create metallb-system namespace...            "
echo "=============================================="
echo ''

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl get ns metallb-system

echo ''
echo "=============================================="
echo "Done: Create metallb-system namespace.        "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Install metallb-system manifest...            "
echo "=============================================="
echo ''

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml

function GetStatus1 {
	kubectl get all -n metallb-system | grep -c Running
}
Status1=$(GetStatus1)

while [ $Status1 -lt 4 ]
do
	Status1=$(GetStatus1)
	sleep 5
done

echo ''
echo "=============================================="
echo "Done: Install metallb-system manifest.        "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Install metallb-system configmap...           "
echo "=============================================="
echo ''

kubectl apply -f metallb-configmap.yaml
kubectl describe configmap config -n metallb-system

echo ''
echo "=============================================="
echo "Done: Install metallb-system configmap.       "
echo "=============================================="
echo ''

sleep 

clear

echo ''
echo "=============================================="
echo "Test metallb-system using nginx deploy...     "
echo "=============================================="
echo ''

kubectl expose deploy nginx --port 80 --type LoadBalancer
kubectl get all | egrep 'EXTERNAL-IP|LoadBalancer'
kubectl delete service nginx

echo ''
echo "=============================================="
echo "Done: Test metallb-system using nginx deploy. "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Done: Install Metallb k8s load balancer.      "
echo "=============================================="
echo ''

sleep 5

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
echo "Install helm...                               "
echo "=============================================="
echo ''

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
echo ''
helm version --short

echo ''
echo "=============================================="
echo "Done: Install helm.                           "
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

