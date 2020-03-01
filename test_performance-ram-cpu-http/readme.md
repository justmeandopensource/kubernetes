# ------------------test performance web cpu----------
pacman -S siege
```
siege -q -c 5 -t 2m http://kworker1:32298
```
-q, --quiet
-c:concurrent nbr de requette http envoyé
-t:time (pour combient de temp)

# -----------test site web with script curl---------
```
for i in {1..35}; do
   kubectl exec --namespace=kube-public curl -- sh -c 'test=`wget -qO- -T 2  http://webapp-service.default.svc.cluster.local:8080/info 2>&1` && echo "$test OK" || echo "Failed"';
   echo ""
```
# ------------------test performance web mem----------
## pod avec stress
-------------------yaml-stress avec container qui consomme 15Mi Ram--------

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2020-02-29T15:54:48Z"
  name: elephant
  namespace: default
  resourceVersion: "1531"
  selfLink: /api/v1/namespaces/default/pods/elephant
  uid: 297fc172-9672-44d8-ba42-32afce3eae58
spec:
  containers:
  - args:
    - --vm
    - "1"
    - --vm-bytes
    - 15M
    - --vm-hang
   - "1"
    command:
    - stress
    image: polinux/stress
    imagePullPolicy: Always
    name: mem-stress
    resources:
      limits:
        memory: 20Mi
      requests:
        memory: 5Mi
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: default-token-wx7qs
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: node01
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  ```
---------------------------------------------------------------


## utiliser la commande stress à l'interieur du conteneur
```
stress --vm 2 --vm-bytes 200M
```

