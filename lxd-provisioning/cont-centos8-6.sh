#!/bin/bash
export KUBECONFIG=/etc/kubernetes/admin.conf

# Deploy metallb load balancer

clear

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
echo ''
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

sleep  5

clear

echo ''
echo "=============================================="
echo "Install metallb-system manifest...            "
echo "=============================================="
echo ''

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml

echo ''
echo "=============================================="
echo "Done: Install metallb-system manifest.        "
echo "=============================================="
echo ''

sleep 5

clear

echo ''
echo "=============================================="
echo "Wait for metallb-system STATUS Running...    "
echo "=============================================="
echo ''

function GetStatus1 {
	kubectl get all -n metallb-system | grep -c Running
}
Status1=$(GetStatus1)

while [ $Status1 -lt 4 ]
do
	Status1=$(GetStatus1)
	echo 'Waiting for metallb-system STATUS Running all containers...'
	echo ''
	kubectl get all -n metallb-system | egrep 'STATUS|Running'
	echo ''
	sleep 10
done

echo ''
echo "=============================================="
echo "Done: Wait for metallb-system STATUS Running. "
echo "=============================================="
echo ''

sleep 5

clear

echo "=============================================="
echo "Test metallb-system using nginx deploy...     "
echo "=============================================="
echo ''

kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type LoadBalancer --port 80
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
