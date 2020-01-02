# [metallb](https://metallb.universe.tf/installation/) quick setup

Metallb is a simple load balancer designed for bare metal kubernetes clusters. Here it is used on vagrant provisioned cluster.

1. Install metallb on the cluster

```bash
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml
```

2. Use Layer2 configuration to setup metallb on the cluster

- check ip ranges of your nodes bu running `kubectl get nodes -owide`

- create config map for the load balancer and sibstitute IP ranges for the ones you get from running `kubectl get nodes -owide`

- I gave 50 IP addresses for the range

``` bash
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.1.240-192.168.1.250
EOF
```

3. Test if load balancer works

- Create deployment for nginx server

`kubectl run nginx --image=nginx --restart=Never`

- expose server via service of type LoadBalancer

`kubectl expose pod nginx --type=LoadBalancer --port 80`

- check if k8s provisioned external IP for the service (wait for IP to be provisioned)

`kubectl get svc -w`

- try to access the service

`curl http://<service IP>`
