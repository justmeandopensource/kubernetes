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

