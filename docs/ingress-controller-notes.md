## Nginx Ingress Controller Notes

#### Clone and deploy ingress controller
```bash
git clone https://github.com/nginxinc/kubernetes-ingress.git
kubectl create -f kubernetes-ingress/deployments/common/ns-and-sa.yaml 
kubectl create -f kubernetes-ingress/deployments/common/default-server-secret.yaml
kubectl create -f kubernetes-ingress/deployments/common/nginx-config.yaml
kubectl create -f kubernetes-ingress/deployments/rbac/rbac.yaml
kubectl create -f kubernetes-ingress/deployments/daemon-set/nginx-ingress.yaml
rm -rf kubernetes-ingress
```

#### Haproxy configuration
```
frontend http_front
  bind *:80
  default_backend http_back

backend http_back
  balance roundrobin
  server kworker1 <ipaddress>:80
  server kworker2 <ipaddress>:80
```
