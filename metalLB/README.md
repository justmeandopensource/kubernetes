# installation metalLB (1er méthode)
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
# installation metalLB (2eme méthode)
editer le fichier yaml MetalLB.yaml et changer la plage des adresses IP externe sur la partie ConfigMap
```
 #wget https://github.com/soufianem370/kubernetes/blob/master/metalLB/metallb.yaml
 #kubect create -f metallb.yaml
 ```

