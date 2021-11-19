#!/bin/bash

# Deploy metallb load balancer

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl get ns
sleep 5
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml

function CountRunningMetallb {
	kubectl get all -n metallb-system | grep -c Running
}
RunningMetallb=$(CountRunningMetallb)

kubectl create configmap config --from-file=/root/configmap
kubectl describe configmap config

# If not using ingress-nginx
# kubectl expose deploy nginx --port 80 --type LoadBalancer

# Deploy ingress-nginx

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get-helm.sh

helm version --short

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
help repo update
helm repo list
helm search repo ingress

# helm show values ingress-nginx/ingress-nginx > ingress-nginx.yaml (this step will be replaced by my customized file in the archive so that it does not need the three edits)

# lxc file push ingress-nginx.yaml -- maestro/root/

helm install orabuntu-lxd ingress-nginx/ingress-nginx -n ingress-nginx --values /root/ingress-nginx.yaml

helm list -n ingress-nginx

kubectl -n ingress-nginx get all

# sudo iptables -t nat -A PREROUTING -p tcp -i enp0s17 --dport 80 -j DNAT --to-destination 10.209.53.240:80

