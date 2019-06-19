## Let's encrypt cert-manager quick reference

#### Haproxy configuration
```
frontend http_front
  bind *:443
  mode tcp
  option tcplog
  default_backend http_back

backend http_back
  mode tcp
  balance roundrobin
  server kworker1 <kworker1-ip>:443
  server kworker2 <kworker2-ip>:443
```

#### Install helm
```
wget https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
tar zxf helm*gz
sudo cp linux-amd64/helm /usr/local/bin/
rm -rf helm* linux-amd64
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
```

*Wait for tiller component to be active*

#### cert-manager setup
```
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm install --name cert-manager --namespace cert-manager jetstack/cert-manager
```

*Wait for cert-manager pods to be active*

```
kubectl create -f https://raw.githubusercontent.com/justmeandopensource/kubernetes/master/yamls/cert-manager-demo/ClusterIssuer.yaml
```
