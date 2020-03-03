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
# install storageClass nfs

```
helm install stable/nfs-client-provisioner --set nfs.server=172.23.0.1 --set nfs.path=/srv/nfs/kubedata
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
## installé grafana 
1) methode :
```
helm install stable/grafana --name mygrafana --set persistence.enabled=true --set persistence.accessModes={ReadWriteOnce} --set persistence.size=8Gi --set service.type=NodePort --set service.nodePort=32221
```
user: admin 
password nous pouvons le récuperé depuis le secret du chart

```
kubectl get secret --namespace default mygrafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
mygrafana: nom du chart

2) méthode
helm inspect stable/grafana > /tmp/grafana.values

vim /tmp/grafana.values
```
service:
  type: NodePort
  port: 80
  nodePort: 32211
  targetPort: 3000
    # targetPort: 4181 To be used with a proxy extraContainer
  annotations: {}
  labels: {}
  portName: service
```
```
kubectl expose deployment grafana1 --type=NodePort --port=80 --target-port=3000
```
user: admin 
password nous pouvons le récuperé depuis le secret du chart

```
kubectl get secret --namespace default mygrafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
mygrafana: nom du chart
