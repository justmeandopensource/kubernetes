List Master nodes
```
kubectl get nodes --selector='node-role.kubernetes.io/master'
```
List worker nodes
```
kubectl get nodes --selector='!node-role.kubernetes.io/master'
```
