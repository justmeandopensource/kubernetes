# kubernetes
Kubernetes playground
# installation metalLB
1) telecharger manifest depuis le site officiel
https://metallb.universe.tf/installation/

kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml

2)ajouter une configMap pour définir la plage IP external
```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: k8s-master-ip-space
      protocol: layer2
      addresses:
      - 172.23.0.100-172.23.0.250                                
```
# installation prometheus avec grafana en utilisant helm
install helm in your cluster
install chart prometheus
```
helm inspect stable/prometheus > /tmp/prom.values
```
change type off service on NodePort
vim /tmp/prom.values
```
    externalIPs: []

    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    servicePort: 80
    nodePort: 31114
    sessionAffinity: None
    type: NodePort
```
```
helm install --values /tmp/prom.values --name myprom1 stable/prometheus
```
### si votre service n'est pas créer en mode NodePort il faut supprimer le service et le recrier manuellement

```
 #kubectl delete svc myprom1-prometheus-server
 #kubectl expose deployment myprom1-prometheus-server --type=NodePort --port=80 --target-port=9090
```

